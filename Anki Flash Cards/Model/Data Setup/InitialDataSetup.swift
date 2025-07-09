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
                collection.priority = language.priority
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
    
    private static func priorityForLanguage(_ language: String) -> Int64 {
        switch language {
        case "Spanish": return 100
        case "French": return 95
        case "Japanese": return 90
        case "German": return 85
        case "Korean": return 80
        case "Italian": return 75
        case "Chinese": return 70
        case "Russian": return 65
        case "Arabic": return 60
        case "Portuguese": return 55
        case "English": return 50
            
        default: return 50
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
