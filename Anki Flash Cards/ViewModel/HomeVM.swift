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
    @Published var navigateToFlashCard = false
    @Published var showingAddCollection = false
    @Published var screenEnterTime: Date? = nil
    @Published var lastActionTime: Date? = nil
    @Published var selectedThemeIndex: Int? = nil
    @Published var selectedLevel: Int? = nil

    @Published var languageCourse: LanguageCourse?
    @Published var themes: [Theme] = []
    private var levelsByTheme: [Int: [Int: [CardData]]] = [:]
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadDataFromCoreData()
    }

    func loadDataFromCoreData() {
        let request: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        request.predicate = NSPredicate(format: "language.name_language == %@", "English")
        do {
            let collections = try viewContext.fetch(request)
            themes = collections.enumerated().map { (index, collection) in
                let cards = (collection.cards?.allObjects as? [ShopCard])?.map { CardData(front: $0.frontText ?? "", back: $0.backText ?? "") } ?? []
                return Theme(title: collection.name ?? "Theme \(index + 1)", cards: cards, imageName: collection.name?.lowercased().replacingOccurrences(of: " ", with: "_") ?? "")
            }
            print("Loaded \(themes.count) themes from Core Data for English")
            Analytics.logEvent("home_coredata_load_success", parameters: ["theme_count": themes.count])
            distributeCardsIntoLevels()
        } catch {
            print("Ошибка при загрузке коллекций из Core Data: \(error)")
            Analytics.logEvent("home_coredata_load_error", parameters: ["error": error.localizedDescription])
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
