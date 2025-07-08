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
        // Получаем список всех JSON-файлов в бандле
        guard let jsonFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            print("Не найдено JSON-файлов в бандле")
            return
        }
        
        // Словарь для отслеживания уже обработанных комбинаций язык+коллекция
        var processedCombinations = Set<String>()
        
        // Проверяем существующие языки и коллекции
        let existingLanguages = fetchExistingLanguages(context: context)
        let existingCollections = fetchExistingCollections(context: context)
        
        // Обрабатываем все JSON-файлы
        for fileURL in jsonFiles {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let cardModel = try decoder.decode(CardModel.self, from: data)
                
                let combinationKey = "\(cardModel.language)|\(cardModel.name)"
                guard !processedCombinations.contains(combinationKey) else { continue }
                processedCombinations.insert(combinationKey)
                
                // Проверяем, существует ли уже такая коллекция
                if existingCollections.contains(where: { $0.name == cardModel.name && $0.language?.name_language == cardModel.language }) {
                    continue
                }
                
                // Находим или создаем язык
                let language = existingLanguages.first(where: { $0.name_language == cardModel.language }) ?? {
                    let newLanguage = ShopLanguages(context: context)
                    newLanguage.name_language = cardModel.language
                    newLanguage.creationDate = Date()
                    newLanguage.priority = priorityForLanguage(cardModel.language)
                    return newLanguage
                }()
                
                // Создаем новую коллекцию
                let collection = ShopCollection(context: context)
                collection.name = cardModel.name
                collection.creationDate = Date()
                collection.priority = "middle"
                collection.language = language
                
                // Создаем карточки
                for cardData in cardModel.cards {
                    let card = ShopCard(context: context)
                    card.frontText = cardData.front
                    card.backText = cardData.back
                    card.creationDate = Date()
                    card.collection = collection
                    card.language = cardModel.language
                    card.collection_name = cardModel.name
                }
                
            } catch {
                print("Ошибка при обработке файла \(fileURL.lastPathComponent): \(error)")
            }
        }
        
        // Сохраняем изменения
        do {
            try context.save()
        } catch {
            print("Ошибка при сохранении начальных данных: \(error)")
        }
    }
    
    private static func fetchExistingLanguages(context: NSManagedObjectContext) -> [ShopLanguages] {
        let request: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка при получении языков: \(error)")
            return []
        }
    }
    
    private static func fetchExistingCollections(context: NSManagedObjectContext) -> [ShopCollection] {
        let request: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка при получении коллекций: \(error)")
            return []
        }
    }
    
    private static func priorityForLanguage(_ language: String) -> String {
        switch language {
        case "Spanish", "English", "Portuguese":
            return "high"
        case "Arabic":
            return "low"
        default:
            return "middle"
        }
    }
}

// Структура для декодирования JSON
struct CardModel: Decodable {
    let language: String
    let name: String
    let cards: [CardData]
}

struct CardData: Decodable {
    let front: String
    let back: String
}


/*
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
                card.frontText = cardEntry.front
                card.backText = cardEntry.back
                card.creationDate = Date()
                card.collection = collection
                cardData.language
                card.collection_name = cardData.name
            }
            
            
        } catch {
            print("Ошибка при загрузке карточек для \(collection_name): \(error)")
        }
    }
}


// Структура для декодирования JSON
struct CardModel: Decodable {
    let language: String
    let name: String
    let cards: [CardData]
}

struct CardData: Decodable {
    let front: String
    let back: String
}
*/
