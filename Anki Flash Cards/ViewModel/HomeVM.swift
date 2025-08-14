//
//  HomeVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-06.
//

import Foundation
import SwiftUI
import CoreData
import FirebaseAnalytics

final class HomeVM: ObservableObject {
    @AppStorage("isFirstOpenKey") var isFirstOpen = false
    @AppStorage("selectedLanguage") var selectedLanguage = "English" // Храним текущий язык
    @Published var navigateToFlashCard = false
    @Published var showingAddCollection = false
    @Published var screenEnterTime: Date? = nil
    @Published var lastActionTime: Date? = nil
    @Published var selectedThemeIndex: Int? = nil
    @Published var selectedLevel: Int? = nil
    @Published var availableLanguages: [LanguageOption] = [] // Список доступных языков

    @Published var languageCourse: LanguageCourse?
    @Published var themes: [Theme] = []
    private var levelsByTheme: [Int: [Int: [CardData]]] = [:]
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadAvailableLanguages()
        loadDataFromCoreData()
        debugCoreDataContents()
    }

    // Загружаем список доступных языков из Core Data
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
            print("🌐 Загружено языков: \(availableLanguages.count)")
            Analytics.logEvent("home_languages_loaded", parameters: ["language_count": availableLanguages.count])
        } catch {
            print("❌ Ошибка при загрузке языков: \(error)")
            Analytics.logEvent("home_languages_load_error", parameters: ["error": error.localizedDescription])
        }
    }

    // Переключение языка
    func switchLanguage(to language: String) {
        guard selectedLanguage != language else { return }
        selectedLanguage = language
        loadDataFromCoreData()
        Analytics.logEvent("home_language_switched", parameters: ["language": language])
    }

    func loadDataFromCoreData() {
        let request: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        request.predicate = NSPredicate(format: "language.name_language == %@", selectedLanguage)
        do {
            let collections = try viewContext.fetch(request)
            print("📚 Найдено коллекций для \(selectedLanguage): \(collections.count)")
            themes = collections.enumerated().map { (index, collection) in
                let cards = (collection.cards?.allObjects as? [ShopCard])?.map { CardData(front: $0.frontText ?? "", back: $0.backText ?? "") } ?? []
                print("Коллекция \(collection.name ?? "N/A"): \(cards.count) карточек")
                return Theme(title: collection.name ?? "Theme \(index + 1)", cards: cards, imageName: collection.name?.lowercased().replacingOccurrences(of: " ", with: "_") ?? "")
            }
            print("Loaded \(themes.count) themes from Core Data for \(selectedLanguage)")
            Analytics.logEvent("home_coredata_load_success", parameters: ["theme_count": themes.count, "language": selectedLanguage])
            distributeCardsIntoLevels()
        } catch {
            print("❌ Ошибка при загрузке коллекций из Core Data для \(selectedLanguage): \(error)")
            Analytics.logEvent("home_coredata_load_error", parameters: ["error": error.localizedDescription, "language": selectedLanguage])
        }
    }

    func debugCoreDataContents() {
        let languageRequest: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        do {
            let languages = try viewContext.fetch(languageRequest)
            print("🌐 Все языки (\(languages.count)):")
            for language in languages {
                print("Язык: \(language.name_language ?? "N/A")")
            }
        } catch {
            print("❌ Ошибка при получении языков: \(error)")
        }
        
        let collectionRequest: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        do {
            let collections = try viewContext.fetch(collectionRequest)
            print("📚 Все коллекции (\(collections.count)):")
            for collection in collections {
                let cardCount = (collection.cards?.allObjects as? [ShopCard])?.count ?? 0
                print("Коллекция: \(collection.name ?? "N/A"), Язык: \(collection.language?.name_language ?? "N/A"), Карточек: \(cardCount)")
            }
        } catch {
            print("❌ Ошибка при получении коллекций: \(error)")
        }
    }

    private func distributeCardsIntoLevels() {
        levelsByTheme.removeAll()
        for (themeIndex, theme) in themes.enumerated() {
            let totalCards = theme.cards.count
            if totalCards == 0 {
                print("Theme \(theme.title) has no cards")
                levelsByTheme[themeIndex] = [:]
                continue
            }

            let cardsPerLevel = max(1, totalCards / 11)
            let remainder = totalCards % 11
            var levelCards: [Int: [CardData]] = [:]
            var cardIndex = 0
            var remainingCards = totalCards

            print("Distributing \(totalCards) cards for theme \(theme.title)")

            for level in 1...11 {
                if remainingCards <= 0 {
                    levelCards[level] = []
                    print("Level \(level): 0 cards (no remaining cards)")
                    continue
                }

                let cardsForThisLevel = (level == 11) ? remainingCards : min(cardsPerLevel, remainingCards)
                let endIndex = cardIndex + cardsForThisLevel
                let cards = Array(theme.cards[cardIndex..<min(endIndex, totalCards)])
                levelCards[level] = cards
                print("Level \(level): \(cards.count) cards")
                cardIndex += cardsForThisLevel
                remainingCards -= cardsForThisLevel
            }
            levelsByTheme[themeIndex] = levelCards
        }
    }

    func getCardsForLevel(themeIndex: Int, level: Int) -> [CardData] {
        let cards = levelsByTheme[themeIndex]?[level] ?? []
        print("Retrieved \(cards.count) cards for theme \(themeIndex), level \(level)")
        return cards
    }

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

    // Функция для получения эмодзи флага по языку
    private func flagForLanguage(_ language: String) -> String {
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

// Структура для представления языка в UI
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
