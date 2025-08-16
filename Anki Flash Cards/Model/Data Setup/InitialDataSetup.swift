//
//  InitialDataSetup.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import CoreData
import FirebaseAnalytics

struct InitialDataSetup {
    static func setupInitialData(context: NSManagedObjectContext) {
        Analytics.logEvent("initial_data_setup_start", parameters: nil)
        let setupStartTime = Date()
        
        // User
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.fetchLimit = 1
        do {
            let existingUsers = try context.fetch(userRequest)
            if existingUsers.isEmpty {
                let newUser = User(context: context)
                newUser.age = 0
                newUser.onboarding_select_language = ""
                newUser.time_study_per_day = 0
                print("✅ User создан")
                Analytics.logEvent("initial_data_setup_user_created", parameters: nil)
            } else {
                print("ℹ️ User уже существует, пропускаем создание")
                Analytics.logEvent("initial_data_setup_user_already_exists", parameters: nil)
            }
        } catch {
            print("❌ Ошибка при проверке/создании User: \(error)")
            Analytics.logEvent("initial_data_setup_user_error", parameters: ["error_description": error.localizedDescription])
        }

        // JSONs
        guard let jsonFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            print("❌ Не найдено JSON-файлов в бандле")
            Analytics.logEvent("initial_data_setup_no_json_files", parameters: nil)
            return
        }
        print("📁 Найдены JSON-файлы: \(jsonFiles.map { $0.lastPathComponent })")
        Analytics.logEvent("initial_data_setup_json_files_found", parameters: ["count": jsonFiles.count])
        
        var processedCombinations = Set<String>()
        let existingLanguages = fetchExistingLanguages(context: context)
        let existingCollections = fetchExistingCollections(context: context)
        var newLanguagesCount = 0
        var newCollectionsCount = 0
        var newCardsCount = 0
        var newQuestionsCount = 0
        var errorFiles = [String]()
        
        // Динамическая проверка наличия сущности/атрибута для вопросов
        let hasShopQuestionEntity = context.persistentStoreCoordinator?
            .managedObjectModel.entitiesByName["ShopQuestion"] != nil
        
        // Проверим, есть ли у ShopCollection атрибут questionsJSON
        let hasQuestionsJSONAttribute: Bool = {
            guard let entity = NSEntityDescription.entity(forEntityName: "ShopCollection", in: context) else { return false }
            return entity.attributesByName["questionsJSON"] != nil
        }()

        for fileURL in jsonFiles {
            let fileStartTime = Date()
            print("🔍 Начало обработки файла: \(fileURL.lastPathComponent)")
            do {
                let data = try Data(contentsOf: fileURL)
                
                // Пытаемся как LanguageCourse
                do {
                    let course = try JSONDecoder().decode(LanguageCourse.self, from: data)
                    print("📄 Успешно декодирован \(fileURL.lastPathComponent) как LanguageCourse")
                    
                    let combinationKey = "\(course.language)|\(course.name)"
                    if processedCombinations.contains(combinationKey) {
                        print("ℹ️ Пропущена дублирующая коллекция: \(course.name)")
                        Analytics.logEvent("initial_data_setup_skipped_duplicate_collection", parameters: ["collection": course.name, "language": course.language])
                        continue
                    }
                    processedCombinations.insert(combinationKey)
                    
                    if existingCollections.contains(where: { $0.name == course.name && $0.language?.name_language == course.language }) {
                        print("ℹ️ Коллекция \(course.name) уже существует")
                        Analytics.logEvent("initial_data_setup_skipped_existing_collection", parameters: ["collection": course.name, "language": course.language])
                        continue
                    }
                    
                    // Язык
                    let language: ShopLanguages
                    if let foundLanguage = existingLanguages.first(where: { $0.name_language == course.language }) {
                        language = foundLanguage
                        print("🌐 Используется существующий язык: \(course.language)")
                    } else {
                        language = ShopLanguages(context: context)
                        language.name_language = course.language
                        language.creationDate = Date()
                        language.priority = priorityForLanguage(course.language)
                        newLanguagesCount += 1
                        print("🌐 Создан новый язык: \(course.language)")
                        Analytics.logEvent("initial_data_setup_new_language_created", parameters: ["language": course.language])
                    }
                    
                    // Коллекции/темы
                    for theme in course.themes {
                        let collection = ShopCollection(context: context)
                        collection.name = theme.title
                        collection.creationDate = Date()
                        collection.priority = language.priority
                        collection.language = language
                        newCollectionsCount += 1
                        print("📚 Создана коллекция: \(theme.title) с \(theme.cards.count) карточками, вопросов: \(theme.questions?.count ?? 0)")
                        
                        // Карточки
                        for cardData in theme.cards {
                            let card = ShopCard(context: context)
                            card.frontText = cardData.front
                            card.backText = cardData.back
                            card.creationDate = Date()
                            card.collection = collection
                            card.language = course.language
                            card.collection_name = theme.title
                            newCardsCount += 1
                        }
                        
                        // ВОПРОСЫ — стратегия 1: сущность ShopQuestion
                        if hasShopQuestionEntity, let qs = theme.questions, !qs.isEmpty {
                            for q in qs {
                                if let questionEntity = NSEntityDescription.entity(forEntityName: "ShopQuestion", in: context) {
                                    let qObj = NSManagedObject(entity: questionEntity, insertInto: context)
                                    qObj.setValue(q, forKey: "text")
                                    qObj.setValue(Date(), forKey: "creationDate")
                                    qObj.setValue(collection, forKey: "collection") // обратная связь
                                    newQuestionsCount += 1
                                }
                            }
                        }
                        // ВОПРОСЫ — стратегия 2: атрибут questionsJSON в ShopCollection
                        else if hasQuestionsJSONAttribute, let qs = theme.questions {
                            do {
                                let data = try JSONEncoder().encode(qs)
                                collection.setValue(data, forKey: "questionsJSON")
                                newQuestionsCount += qs.count
                            } catch {
                                print("⚠️ Не удалось закодировать questionsJSON для '\(theme.title)': \(error)")
                            }
                        } else {
                            if let count = theme.questions?.count, count > 0 {
                                print("⚠️ Вопросы есть (\(count)), но в Core Data нет ни ShopQuestion, ни questionsJSON — пропускаем сохранение.")
                            }
                        }
                    }
                    
                    let fileDuration = Date().timeIntervalSince(fileStartTime)
                    Analytics.logEvent("initial_data_setup_file_processed", parameters: [
                        "file": fileURL.lastPathComponent,
                        "language": course.language,
                        "collection_count": course.themes.count,
                        "cards_count": course.themes.reduce(0) { $0 + $1.cards.count },
                        "questions_count": course.themes.reduce(0) { $0 + ($1.questions?.count ?? 0) },
                        "duration_sec": fileDuration
                    ])
                } catch {
                    // как CardModel (обратная совместимость)
                    print("⚠️ Не удалось декодировать \(fileURL.lastPathComponent) как LanguageCourse: \(error)")
                    let cardModel = try JSONDecoder().decode(CardModel.self, from: data)
                    print("📄 Успешно декодирован \(fileURL.lastPathComponent) как CardModel")
                    
                    let combinationKey = "\(cardModel.language)|\(cardModel.name)"
                    if processedCombinations.contains(combinationKey) {
                        print("ℹ️ Пропущена дублирующая коллекция: \(cardModel.name)")
                        Analytics.logEvent("initial_data_setup_skipped_duplicate_collection", parameters: ["collection": cardModel.name, "language": cardModel.language])
                        continue
                    }
                    processedCombinations.insert(combinationKey)
                    
                    if existingCollections.contains(where: { $0.name == cardModel.name && $0.language?.name_language == cardModel.language }) {
                        print("ℹ️ Коллекция \(cardModel.name) уже существует")
                        Analytics.logEvent("initial_data_setup_skipped_existing_collection", parameters: ["collection": cardModel.name, "language": cardModel.language])
                        continue
                    }
                    
                    // Язык
                    let language: ShopLanguages
                    if let foundLanguage = existingLanguages.first(where: { $0.name_language == cardModel.language }) {
                        language = foundLanguage
                        print("🌐 Используется существующий язык: \(cardModel.language)")
                    } else {
                        language = ShopLanguages(context: context)
                        language.name_language = cardModel.language
                        language.creationDate = Date()
                        language.priority = priorityForLanguage(cardModel.language)
                        newLanguagesCount += 1
                        print("🌐 Создан новый язык: \(cardModel.language)")
                        Analytics.logEvent("initial_data_setup_new_language_created", parameters: ["language": cardModel.language])
                    }
                    
                    // Коллекция
                    let collection = ShopCollection(context: context)
                    collection.name = cardModel.name
                    collection.creationDate = Date()
                    collection.priority = language.priority
                    collection.language = language
                    newCollectionsCount += 1
                    print("📚 Создана коллекция: \(cardModel.name) с \(cardModel.cards.count) карточками")
                    
                    for cardData in cardModel.cards {
                        let card = ShopCard(context: context)
                        card.frontText = cardData.front
                        card.backText = cardData.back
                        card.creationDate = Date()
                        card.collection = collection
                        card.language = cardModel.language
                        card.collection_name = cardModel.name
                        newCardsCount += 1
                    }
                    
                    let fileDuration = Date().timeIntervalSince(fileStartTime)
                    Analytics.logEvent("initial_data_setup_file_processed", parameters: [
                        "file": fileURL.lastPathComponent,
                        "language": cardModel.language,
                        "collection": cardModel.name,
                        "cards_count": cardModel.cards.count,
                        "duration_sec": fileDuration
                    ])
                }
            } catch {
                print("❌ Ошибка при обработке файла \(fileURL.lastPathComponent): \(error)")
                Analytics.logEvent("initial_data_setup_file_error", parameters: [
                    "file": fileURL.lastPathComponent,
                    "error_description": error.localizedDescription
                ])
                errorFiles.append(fileURL.lastPathComponent)
            }
        }
        
        // Save
        do {
            try context.save()
            print("💾 Данные сохранены: \(newLanguagesCount) языков, \(newCollectionsCount) коллекций, \(newCardsCount) карточек, \(newQuestionsCount) вопросов")
            Analytics.logEvent("initial_data_setup_save_success", parameters: [
                "new_languages": newLanguagesCount,
                "new_collections": newCollectionsCount,
                "new_cards": newCardsCount,
                "new_questions": newQuestionsCount
            ])
        } catch {
            print("❌ Ошибка при сохранении начальных данных: \(error)")
            Analytics.logEvent("initial_data_setup_save_error", parameters: ["error_description": error.localizedDescription])
        }
        
        // Отладка
        let allCollections = fetchExistingCollections(context: context)
        print("📋 Все коллекции в Core Data (\(allCollections.count)):")
        for collection in allCollections {
            print("Коллекция: \(collection.name ?? "N/A"), Язык: \(collection.language?.name_language ?? "N/A"), Карточек: \((collection.cards?.count ?? 0))")
        }
        
        let setupDuration = Date().timeIntervalSince(setupStartTime)
        Analytics.logEvent("initial_data_setup_complete", parameters: [
            "duration_sec": setupDuration,
            "new_languages": newLanguagesCount,
            "new_collections": newCollectionsCount,
            "new_cards": newCardsCount,
            "new_questions": newQuestionsCount,
            "error_files_count": errorFiles.count
        ])
    }
    
    // MARK: helpers
    private static func fetchExistingLanguages(context: NSManagedObjectContext) -> [ShopLanguages] {
        let request: NSFetchRequest<ShopLanguages> = ShopLanguages.fetchRequest()
        do {
            let langs = try context.fetch(request)
            print("🌐 Найдено языков: \(langs.count)")
            Analytics.logEvent("initial_data_setup_fetch_languages_success", parameters: ["count": langs.count])
            return langs
        } catch {
            print("❌ Ошибка при получении языков: \(error)")
            Analytics.logEvent("initial_data_setup_fetch_languages_error", parameters: ["error_description": error.localizedDescription])
            return []
        }
    }
    
    private static func fetchExistingCollections(context: NSManagedObjectContext) -> [ShopCollection] {
        let request: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        do {
            let cols = try context.fetch(request)
            print("📚 Найдено коллекций: \(cols.count)")
            Analytics.logEvent("initial_data_setup_fetch_collections_success", parameters: ["count": cols.count])
            return cols
        } catch {
            print("❌ Ошибка при получении коллекций: \(error)")
            Analytics.logEvent("initial_data_setup_fetch_collections_error", parameters: ["error_description": error.localizedDescription])
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

// Обратная совместимость со старыми JSON-колодами без тем
struct CardModel: Decodable {
    let language: String
    let name: String
    let cards: [CardData]
}

