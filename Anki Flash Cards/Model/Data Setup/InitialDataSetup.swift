//
//  InitialDataSetup.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import CoreData
import SwiftUI

struct InitialDataSetup {
    static func setupInitialData(context: NSManagedObjectContext) {
        // Проверяем, были ли данные уже инициализированы
        let languageRequest: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        let languageCount = try? context.count(for: languageRequest)
        
        guard languageCount == 0 else { return } // Если языки уже есть, выходим
        
        // Список языков, для которых есть JSON-файлы
        let languages = [
            "Spanish", "English", "French", "German", "Chinese",
            "Japanese", "Russian", "Italian", "Portuguese", "Arabic"
        ]
        
        // Проверяем существующие коллекции
        let collectionRequest: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        let existingCollections = try? context.fetch(collectionRequest)
        let existingNames = Set(existingCollections?.map { $0.name ?? "" } ?? [])
        
        // Создаем языки и коллекции с данными из JSON
        for languageName in languages where !existingNames.contains(languageName) {
            let language = ShopLanguages(context: context)
            language.name_language = languageName
            language.creationDate = Date()
            language.priority = "middle"
            
            if language.name_language == "Spanish" {
                language.priority = "high"
            } else if language.name_language == "English" {
                language.priority = "high"
            } else if language.name_language == "French" {
                language.priority = "middle"
            } else if language.name_language == "German" {
                language.priority = "middle"
            } else if language.name_language == "Chinese" {
                language.priority = "middle"
            } else if language.name_language == "Japanese" {
                language.priority = "middle"
            } else if language.name_language == "Russian" {
                language.priority = "middle"
            } else if language.name_language == "Italian" {
                language.priority = "middle"
            } else if language.name_language == "Portuguese" {
                language.priority = "high"
            } else if language.name_language == "Arabic" {
                language.priority = "low"
            } else {
                language.priority = "middle"
            }
            
            let collection = ShopCollection(context: context)
            collection.name = languageName
            collection.creationDate = Date()
            collection.priority = "middle"
            
            // Связь коллекции с языком
            collection.language = language
            if let collections = language.language_collections as? Set<ShopCollection> {
                let mutableCollections = NSMutableSet(set: collections)
                mutableCollections.add(collection)
                language.language_collections = mutableCollections as NSSet
            } else {
                language.language_collections = NSSet(object: collection)
            }
            
            // Загрузка карточек из JSON
            loadCardsFromJSON(for: collection, context: context)
        }
        
        // Сохраняем изменения
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении начальных данных: \(error)")
        }
    }
    
    private static func loadCardsFromJSON(for collection: ShopCollection, context: NSManagedObjectContext) {
        guard let collection_name = collection.name else { return }
        
        // Загрузка JSON-файла из бандла
        guard let url = Bundle.main.url(forResource: collection_name, withExtension: "json") else {
            print("JSON-файл для \(collection_name) не найден")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let cardData = try decoder.decode(CardModel.self, from: data)
            
            // Создание ShopCard для каждой записи
            for cardEntry in cardData.cards {
                let card = ShopCard(context: context)
                card.collection_name = cardData.name
                card.frontText = cardEntry.front
                card.backText = cardEntry.back
                card.creationDate = Date()
                card.collection = collection
            }
        } catch {
            print("Ошибка при загрузке карточек для \(collection_name): \(error)")
        }
    }
}


// Структура для декодирования JSON
struct CardModel: Decodable {
    let name: String
    let cards: [CardData]
}

struct CardData: Decodable {
    let front: String
    let back: String
}
