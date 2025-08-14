//
//  HomeVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-06.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

// MARK: - HomeVM
final class HomeVM: ObservableObject {
    @AppStorage("isFirstOpenKey") var isFirstOpen = false
    @AppStorage("selectedLanguage") var selectedLanguage = "English"
    @AppStorage("currentStreak") var currentStreak: Int = 0
    @AppStorage("totalTimeSpent") var totalTimeSpent: Double = 0 // в секундах

    @Published var navigateToFlashCard = false
    @Published var showingAddCollection = false
    @Published var screenEnterTime: Date? = nil
    @Published var lastActionTime: Date? = nil
    @Published var selectedThemeIndex: Int? = nil
    @Published var selectedLevel: Int? = nil
    @Published var availableLanguages: [LanguageOption] = []
    @Published var languageCourse: LanguageCourse?
    @Published var themes: [Theme] = []
    @Published var studiedCardsCount: Int = 0
    @Published var starsCount: Int = 0
    @Published var currentThemeIndex: Int = 0

    var currentTheme: Theme? {
        guard themes.indices.contains(currentThemeIndex) else { return nil }
        return themes[currentThemeIndex]
    }

    private var levelsByTheme: [Int: [Int: [CardData]]] = [:]
    @AppStorage("levelProgressDict") private var levelProgressDictJSON: String = "{}"
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadAvailableLanguages()
        loadDataFromCoreData()
        fetchStudiedCardsCount()
        debugCoreDataContents()
    }

    // MARK: - Languages
    func loadAvailableLanguages() {
        let request: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        do {
            let languages = try viewContext.fetch(request)
            availableLanguages = languages.map { language in
                LanguageOption(
                    name: language.name_language ?? "Unknown",
                    flag: flagForLanguage(language.name_language ?? "Unknown")
                )
            }
            Analytics.logEvent("home_languages_loaded", parameters: ["language_count": availableLanguages.count])
        } catch {
            Analytics.logEvent("home_languages_load_error", parameters: ["error": error.localizedDescription])
        }
    }

    func switchLanguage(to language: String) {
        guard selectedLanguage != language else { return }
        selectedLanguage = language
        loadDataFromCoreData()
        fetchStudiedCardsCount()
        currentThemeIndex = 0
        Analytics.logEvent("home_language_switched", parameters: ["language": language])
    }

    // MARK: - CoreData loading
    func loadDataFromCoreData() {
        let request: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        request.predicate = NSPredicate(format: "language.name_language == %@", selectedLanguage)
        do {
            let collections = try viewContext.fetch(request)
            themes = collections.enumerated().map { (index, collection) in
                let cards = (collection.cards?.allObjects as? [ShopCard])?
                    .map { CardData(front: $0.frontText ?? "", back: $0.backText ?? "") } ?? []
                return Theme(
                    title: collection.name ?? "Theme \(index + 1)",
                    cards: cards,
                    imageName: collection.name?.lowercased().replacingOccurrences(of: " ", with: "_") ?? ""
                )
            }
            distributeCardsIntoLevels()
            currentThemeIndex = min(currentThemeIndex, max(0, themes.count - 1))
            Analytics.logEvent("home_coredata_load_success", parameters: ["theme_count": themes.count, "language": selectedLanguage])
        } catch {
            Analytics.logEvent("home_coredata_load_error", parameters: ["error": error.localizedDescription, "language": selectedLanguage])
        }
    }

    func debugCoreDataContents() {
        let languageRequest: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        if let languages = try? viewContext.fetch(languageRequest) {
            print("🌐 Все языки (\(languages.count)):")
            for language in languages {
                print("Язык: \(language.name_language ?? "N/A")")
            }
        }

        let collectionRequest: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        if let collections = try? viewContext.fetch(collectionRequest) {
            print("📚 Все коллекции (\(collections.count)):")
            for collection in collections {
                let cardCount = (collection.cards?.allObjects as? [ShopCard])?.count ?? 0
                print("Коллекция: \(collection.name ?? "N/A"), Язык: \(collection.language?.name_language ?? "N/A"), Карточек: \(cardCount)")
            }
        }

        let cardRequest: NSFetchRequest<Card> = Card.fetchRequest()
        if let cards = try? viewContext.fetch(cardRequest) {
            print("🃏 Все карточки (\(cards.count)):")
            for card in cards {
                print("Карточка: front=\(card.frontText ?? "N/A"), back=\(card.backText ?? "N/A"), grade=\(card.lastGrade.rawValue), isNew=\(card.isNew)")
            }
        }
    }

    // MARK: - Разбивка карточек по уровням
    private func distributeCardsIntoLevels() {
        levelsByTheme.removeAll()
        for (themeIndex, theme) in themes.enumerated() {
            let totalCards = theme.cards.count
            guard totalCards > 0 else {
                levelsByTheme[themeIndex] = [:]
                continue
            }
            let base = max(1, totalCards / 11)
            var remaining = totalCards
            var start = 0
            var map: [Int: [CardData]] = [:]
            for level in 1...11 {
                if remaining <= 0 {
                    map[level] = []
                    continue
                }
                let take = (level == 11) ? remaining : min(base, remaining)
                let end = min(start + take, totalCards)
                map[level] = Array(theme.cards[start..<end])
                start = end
                remaining = totalCards - end
            }
            levelsByTheme[themeIndex] = map
        }
    }

    func getCardsForLevel(themeIndex: Int, level: Int, createIfMissing: Bool = false) -> [Card] {
        let cardDatas = levelsByTheme[themeIndex]?[level] ?? []
        var cards: [Card] = []
        for cardData in cardDatas {
            let request: NSFetchRequest<Card> = Card.fetchRequest()
            request.predicate = NSPredicate(format: "frontText == %@ AND backText == %@", cardData.front, cardData.back)
            if let existing = try? viewContext.fetch(request).first {
                cards.append(existing)
            } else if createIfMissing {
                let newCard = Card(context: viewContext)
                newCard.frontText = cardData.front
                newCard.backText = cardData.back
                newCard.isNew = true
                newCard.lastGrade = .new
                cards.append(newCard)
            }
        }
        if createIfMissing && !cards.isEmpty {
            do {
                try viewContext.save()
                Analytics.logEvent("home_cards_created", parameters: [
                    "themeIndex": themeIndex,
                    "level": level,
                    "cardCount": cards.count
                ])
            } catch {
                print("Error saving cards: \(error)")
                Analytics.logEvent("home_cards_save_error", parameters: ["error": error.localizedDescription])
            }
        }
        return cards
    }

    func progressForLevel(themeIndex: Int, level: Int) -> Double {
        let cards = getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: false)
        let goodCount = cards.filter { $0.lastGrade == .good }.count
        let total = levelsByTheme[themeIndex]?[level]?.count ?? 1
        return Double(goodCount) / Double(total)
    }

    func checkLevelCompletion(themeIndex: Int, level: Int) {
        let cards = getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: false)
        let allGood = cards.allSatisfy { $0.lastGrade == .good }
        print("Checking level completion: theme \(themeIndex), level \(level), allGood: \(allGood), card count: \(cards.count)")
        Analytics.logEvent("check_level_completion", parameters: [
            "themeIndex": themeIndex,
            "level": level,
            "allGood": allGood,
            "cardCount": cards.count
        ])
        if allGood {
            markLevelCompleted(themeIndex: themeIndex, level: level)
            objectWillChange.send()
        }
    }

    // MARK: - Прогресс по темам и уровням
    func isLevelCompleted(themeIndex: Int, level: Int) -> Bool {
        level <= maxPassedLevel(themeIndex: themeIndex)
    }

    func isThemeUnlocked(themeIndex: Int) -> Bool {
        guard themeIndex > 0 else { return true }
        for i in 0..<themeIndex {
            if maxPassedLevel(themeIndex: i) < 11 { return false }
        }
        return true
    }

    func isLevelUnlocked(themeIndex: Int, level: Int) -> Bool {
        guard isThemeUnlocked(themeIndex: themeIndex) else { return false }
        if themeIndex == 0 && level == 1 { return true }
        let maxPassed = maxPassedLevel(themeIndex: themeIndex)
        return level <= maxPassed + 1
    }

    func markLevelCompleted(themeIndex: Int, level: Int) {
        let key = progressKey(themeIndex: themeIndex)
        var dict = loadProgressDict()
        let current = dict[key] ?? 0
        if level > current {
            dict[key] = min(level, 11)
            saveProgressDict(dict)
            print("Level completed: theme \(themeIndex), level \(level), progress dict: \(dict)")
            Analytics.logEvent("home_level_completed", parameters: [
                "language": selectedLanguage,
                "theme": themes[safe: themeIndex]?.title ?? "N/A",
                "level": level
            ])
            objectWillChange.send()
        }
    }

    func resetThemeProgress(themeIndex: Int) {
        var dict = loadProgressDict()
        dict[progressKey(themeIndex: themeIndex)] = 0
        saveProgressDict(dict)
    }

    func maxPassedLevel(themeIndex: Int) -> Int {
        loadProgressDict()[progressKey(themeIndex: themeIndex)] ?? 0
    }

    private func progressKey(themeIndex: Int) -> String {
        let themeName = themes[safe: themeIndex]?.title ?? "unknown"
        return "\(selectedLanguage)::\(themeName)"
    }

    private func loadProgressDict() -> [String: Int] {
        guard let data = levelProgressDictJSON.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
    }

    private func saveProgressDict(_ dict: [String: Int]) {
        let data = (try? JSONEncoder().encode(dict)) ?? Data()
        levelProgressDictJSON = String(data: data, encoding: .utf8) ?? "{}"
        objectWillChange.send()
    }

    // MARK: - Верхняя панель: счётчики
    func fetchStudiedCardsCount() {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isNew == false")
        do {
            let count = try viewContext.count(for: request)
            studiedCardsCount = count
            starsCount = max(0, count / 10)
            Analytics.logEvent("profile_data_loaded", parameters: [
                "studied_cards": count,
                "stars_count": starsCount,
                "current_streak": currentStreak,
                "total_time_spent_minutes": Int(totalTimeSpent) / 60
            ])
        } catch {
            studiedCardsCount = 0
        }
    }

    // MARK: - Навигационные/временные метрики
    func logTimeSinceLastAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("home_action_interval", parameters: [
                "event": event,
                "interval_since_last": interval
            ])
        }
        lastActionTime = now
    }

    func updateCurrentThemeIndex(_ index: Int) {
        guard themes.indices.contains(index) else { return }
        if currentThemeIndex != index {
            currentThemeIndex = index
            Analytics.logEvent("home_current_theme_changed", parameters: [
                "language": selectedLanguage,
                "theme": themes[index].title
            ])
        }
    }

    // MARK: - Flag
    func flagForLanguage(_ language: String) -> String {
        switch language {
        case "English": return "🇬🇧"
        case "Spanish": return "🇪🇸"
        case "French": return "🇫🇷"
        case "German": return "🇩🇪"
        case "Italian": return "🇮🇹"
        case "Japanese": return "🇯🇵"
        case "Chinese": return "🇨🇳"
        case "Russian": return "🇷🇺"
        case "Arabic": return "🇸🇦"
        case "Portuguese": return "🇵🇹"
        case "Korean": return "🇰🇷"
        default: return "🏳️"
        }
    }
}

// MARK: - Models
struct LanguageOption: Identifiable {
    let id = UUID()
    let name: String
    let flag: String
}

struct LanguageCourse: Decodable {
    let language: String
    let name: String
    let themes: [JSONTheme]
}

struct JSONTheme: Decodable {
    let title: String
    let cards: [CardData]
}

struct Theme {
    let title: String
    let cards: [CardData]
    let imageName: String
}

struct CardData: Decodable {
    let front: String
    let back: String
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
