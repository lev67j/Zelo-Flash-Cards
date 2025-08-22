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

    // levelsByTheme: deterministic split of cards into levels (1..11)
    private var levelsByTheme: [Int: [Int: [CardData]]] = [:]
    
    // NEW: deterministic split of questions into levels (1..11), mirroring cards
    private var levelsByThemeForQuestions: [Int: [Int: [String]]] = [:]

    // progress dictionary stored as JSON in AppStorage (keyed by language::themeIndex -> maxPassedLevel)
    @AppStorage("levelProgressDict") private var levelProgressDictJSON: String = "{}"
    // explicit mapping of created Card objectID.uriRepresentation strings per themeIndex+level
    @AppStorage("levelCardMapJSON") private var levelCardMapJSON: String = "{}"

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
            
            // Жёсткий порядок
            let desiredOrder = [
                "Personal Identity",
                "Daily Routine",
                "Travel & Transportation",
                "Food & Drink",
                "Health & Body",
                "Shopping & Money",
                "Housing & Household",
                "Emergencies & Survival",
                "Work & Career",
                "Technology & Gadgets",
                "Relationships & Communication",
                "Emotions & Mindset",
                "Culture & Entertainment",
                "Education & Learning",
                "Nature & Environment",
                "Social Issues & News"
            ]
            let orderMap = Dictionary(uniqueKeysWithValues: desiredOrder.enumerated().map { ($1, $0) })
            
            let sortedCollections = collections.sorted { a, b in
                let idxA = orderMap[a.name ?? ""] ?? Int.max
                let idxB = orderMap[b.name ?? ""] ?? Int.max
                return idxA < idxB
            }
            
            // Проверка наличия сущности/атрибута для вопросов
            let hasShopQuestionEntity = viewContext.persistentStoreCoordinator?
                .managedObjectModel.entitiesByName["ShopQuestion"] != nil
            
            let hasQuestionsJSONAttribute: Bool = {
                guard let entity = NSEntityDescription.entity(forEntityName: "ShopCollection", in: viewContext) else { return false }
                return entity.attributesByName["questionsJSON"] != nil
            }()
            
            themes = sortedCollections.enumerated().map { (index, collection) in
                // Cards
                let cards = (collection.cards?.allObjects as? [ShopCard])?
                    .sorted(by: { ($0.frontText ?? "") < ($1.frontText ?? "") }) ?? []
                
                // Questions
                var questions: [String] = []
                
                if hasShopQuestionEntity, let set = collection.value(forKey: "questions") as? NSSet {
                    let qObjects = (set.allObjects as? [NSManagedObject]) ?? []
                    questions = qObjects.compactMap { $0.value(forKey: "text") as? String }
                        .sorted()
                } else if hasQuestionsJSONAttribute, let data = collection.value(forKey: "questionsJSON") as? Data {
                    if let qs = try? JSONDecoder().decode([String].self, from: data) {
                        questions = qs
                    }
                } else {
                    // нет хранения — окей, идём без вопросов
                }
                
                return Theme(
                    title: collection.name ?? "Theme \(index + 1)",
                    questions: questions,
                    cards: cards.map { CardData(front: $0.frontText ?? "", back: $0.backText ?? "") },
                    imageName: collection.name?.lowercased().replacingOccurrences(of: " ", with: "_") ?? ""
                )
            }
            
            distributeCardsIntoLevels()
            distributeQuestionsIntoLevels() // NEW: Distribute questions after cards
            
            currentThemeIndex = min(currentThemeIndex, max(0, themes.count - 1))
            
        } catch {
            print("Error loading themes: \(error)")
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
            // Deterministic distribution: try to make levels as equal as possible, earlier levels get 1 extra if remainder
            var map: [Int: [CardData]] = [:]
            let base = totalCards / 11
            var remainder = totalCards % 11
            var cursor = 0
            for level in 1...11 {
                let take = base + (remainder > 0 ? 1 : 0)
                remainder = max(0, remainder - 1)
                let end = min(cursor + take, totalCards)
                if take > 0 && cursor < end {
                    map[level] = Array(theme.cards[cursor..<end])
                } else {
                    map[level] = []
                }
                cursor = end
            }
            levelsByTheme[themeIndex] = map
        }
    }
    
    // NEW: Разбивка вопросов по уровням (mirroring cards distribution)
    private func distributeQuestionsIntoLevels() {
        levelsByThemeForQuestions.removeAll()
        for (themeIndex, theme) in themes.enumerated() {
            let totalQuestions = theme.questions.count
            guard totalQuestions > 0 else {
                levelsByThemeForQuestions[themeIndex] = [:]
                continue
            }
            // Deterministic distribution: try to make levels as equal as possible, earlier levels get 1 extra if remainder
            var map: [Int: [String]] = [:]
            let base = totalQuestions / 11
            var remainder = totalQuestions % 11
            var cursor = 0
            for level in 1...11 {
                let take = base + (remainder > 0 ? 1 : 0)
                remainder = max(0, remainder - 1)
                let end = min(cursor + take, totalQuestions)
                if take > 0 && cursor < end {
                    map[level] = Array(theme.questions[cursor..<end])
                } else {
                    map[level] = []
                }
                cursor = end
            }
            levelsByThemeForQuestions[themeIndex] = map
        }
    }

    // MARK: - Level <-> Card mapping and fetching
    // To avoid collisions between cards from different themes (same front/back), we persist created Card objectIDs per themeIndex+level.
    private func levelCardMapKey(themeIndex: Int, level: Int) -> String {
        return "\(selectedLanguage)::themeIndex:\(themeIndex)::level:\(level)"
    }

    private func loadLevelCardMap() -> [String: [String]] {
        guard let data = levelCardMapJSON.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: [String]].self, from: data)) ?? [:]
    }

    private func saveLevelCardMap(_ map: [String: [String]]) {
        let data = (try? JSONEncoder().encode(map)) ?? Data()
        levelCardMapJSON = String(data: data, encoding: .utf8) ?? "{}"
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    /// Возвращает реальные CoreData Card объекты для themeIndex/level.
    /// Если createIfMissing == true — создаёт Card'ы и сохраняет их objectID'ы в levelCardMap.
    func getCardsForLevel(themeIndex: Int, level: Int, createIfMissing: Bool = false) -> [Card] {
        // 1. try load mapping
        var result: [Card] = []
        let mapKey = levelCardMapKey(themeIndex: themeIndex, level: level)
        var cardMap = loadLevelCardMap()
        if let uriStrings = cardMap[mapKey], !uriStrings.isEmpty {
            for uri in uriStrings {
                if let url = URL(string: uri), let objID = viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) {
                    if let card = try? viewContext.existingObject(with: objID) as? Card {
                        result.append(card)
                    }
                }
            }
            // If mapping existed but some objects missing, fallthrough to attempt to (re)create from CardData
            if !result.isEmpty || !createIfMissing { return result }
        }

        // 2. fallback: create/fetch by content
        let cardDatas = levelsByTheme[themeIndex]?[level] ?? []
        var createdOrFound: [Card] = []
        for cardData in cardDatas {
            // Try to find an exact Card matching front+back and language (if Card has language attribute — if not, we still match content)
            let request: NSFetchRequest<Card> = Card.fetchRequest()
            request.predicate = NSPredicate(format: "frontText == %@ AND backText == %@", cardData.front, cardData.back)
            if let existing = try? viewContext.fetch(request).first {
                createdOrFound.append(existing)
            } else if createIfMissing {
                let newCard = Card(context: viewContext)
                newCard.frontText = cardData.front
                newCard.backText = cardData.back
                newCard.isNew = true
                newCard.lastGrade = .new
                createdOrFound.append(newCard)
            }
        }

        if createIfMissing && !createdOrFound.isEmpty {
            do {
                try viewContext.save()
                // persist mapping
                let uris = createdOrFound.map { $0.objectID.uriRepresentation().absoluteString }
                cardMap[mapKey] = uris
                saveLevelCardMap(cardMap)
                Analytics.logEvent("home_cards_created", parameters: [
                    "themeIndex": themeIndex,
                    "level": level,
                    "cardCount": createdOrFound.count
                ])
            } catch {
                print("Error saving cards: \(error)")
                Analytics.logEvent("home_cards_save_error", parameters: ["error": error.localizedDescription])
            }
        }

        return createdOrFound
    }
    
    // NEW: Returns questions for a specific theme and level (deterministic, no creation needed)
    func getQuestionsForLevel(themeIndex: Int, level: Int) -> [String] {
        return levelsByThemeForQuestions[themeIndex]?[level] ?? []
    }

    // MARK: - Progress and completion logic
    func progressForLevel(themeIndex: Int, level: Int) -> Double {
        let cards = getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: false)
        let goodCount = cards.filter { $0.lastGrade == .good }.count
        let total = levelsByTheme[themeIndex]?[level]?.count ?? cards.count
        guard total > 0 else { return 0.0 }
        return Double(goodCount) / Double(total)
    }

    func checkLevelCompletion(themeIndex: Int, level: Int) {
        let cards = getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: false)
        let allGood = !cards.isEmpty && cards.allSatisfy { $0.lastGrade == .good }
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

    func isLevelCompleted(themeIndex: Int, level: Int) -> Bool {
        return level <= maxPassedLevel(themeIndex: themeIndex)
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
        var dict = loadProgressDict()
        let key = progressKey(themeIndex: themeIndex)
        let current = dict[key] ?? 0
        if level > current {
            dict[key] = min(level, 11)
            saveProgressDict(dict)
            print("Level completed: theme \(themeIndex), level \(level), progress dict: \(dict)")
            Analytics.logEvent("home_level_completed", parameters: [
                "language": selectedLanguage,
                "themeIndex": themeIndex,
                "level": level,
                "theme": themes[safe: themeIndex]?.title ?? "N/A"
            ])
            // unlock next level implicitly via isLevelUnlocked logic
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
        // Use stable key: language + numeric themeIndex, avoids title collisions and ordering issues.
        return "\(selectedLanguage)::themeIndex:\(themeIndex)"
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
    let questions: [String]?
    let cards: [CardData]
}

struct Theme {
    let title: String
    let questions: [String]
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
