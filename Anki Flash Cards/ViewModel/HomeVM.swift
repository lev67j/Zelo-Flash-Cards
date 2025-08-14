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
    // MARK: AppStorage / State
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

    // счётчики для топ-бара
    @Published var studiedCardsCount: Int = 0
    @Published var starsCount: Int = 0

    // текущая тема для "таблички темы"
    @Published var currentThemeIndex: Int = 0
    var currentTheme: Theme? {
        guard themes.indices.contains(currentThemeIndex) else { return nil }
        return themes[currentThemeIndex]
    }

    // Разбивка карточек по уровням: [themeIndex: [level: [CardData]]]
    private var levelsByTheme: [Int: [Int: [CardData]]] = [:]

    // Прогресс уровней: ключ — язык::тема, значение — максимальный пройденный уровень (0 если ничего)
    @AppStorage("levelProgressDict") private var levelProgressDictJSON: String = "{}"

    private let viewContext: NSManagedObjectContext

    // MARK: Init
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
        // при смене языка возвращаемся к первой теме
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
    }

    // MARK: - Разбивка карточек по уровням (1...11)
    private func distributeCardsIntoLevels() {
        levelsByTheme.removeAll()
        for (themeIndex, theme) in themes.enumerated() {
            let totalCards = theme.cards.count
            guard totalCards > 0 else {
                levelsByTheme[themeIndex] = [:]
                continue
            }

            // Равномерное распределение, остаток докидываем в последний уровень
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

    func getCardsForLevel(themeIndex: Int, level: Int) -> [CardData] {
        levelsByTheme[themeIndex]?[level] ?? []
    }

    // MARK: - Прогресс по темам и уровням

    /// Завершён ли уровень (пройден)
    func isLevelCompleted(themeIndex: Int, level: Int) -> Bool {
        level <= maxPassedLevel(themeIndex: themeIndex)
    }

    /// Можно ли открыть тему
    func isThemeUnlocked(themeIndex: Int) -> Bool {
        guard themeIndex > 0 else { return true } // первая тема доступна всегда
        // все предыдущие темы должны быть пройдены полностью
        for i in 0..<(themeIndex) {
            if maxPassedLevel(themeIndex: i) < 11 { return false }
        }
        return true
    }

    /// Можно ли открыть конкретный уровень темы
    func isLevelUnlocked(themeIndex: Int, level: Int) -> Bool {
        guard isThemeUnlocked(themeIndex: themeIndex) else { return false }
        let maxPassed = maxPassedLevel(themeIndex: themeIndex)
        // первый уровень первой темы — доступен по дефолту
        if themeIndex == 0 && level == 1 { return true }
        return level <= maxPassed + 1
    }

    /// Пометить уровень как завершённый
    func markLevelCompleted(themeIndex: Int, level: Int) {
        let key = progressKey(themeIndex: themeIndex)
        var dict = loadProgressDict()
        let current = dict[key] ?? 0
        if level > current {
            dict[key] = min(level, 11)
            saveProgressDict(dict)
            Analytics.logEvent("home_level_completed", parameters: [
                "language": selectedLanguage,
                "theme": themes[safe: themeIndex]?.title ?? "N/A",
                "level": level
            ])
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

    // MARK: - Текущая тема для «таблички»
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

// MARK: - Safe subscript
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
