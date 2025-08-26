//
//  Persistence.swift
//  Anki Flash Cards
//
//  Created by Lev Vlasov on 2025-05-30.
//

import CoreData

struct PersistenceController {
    // singleton
    static let shared = PersistenceController()

    @MainActor
    // экземпляр для предпросмотра
    static let preview: PersistenceController = {
        // Создаём PersistenceController, но только в памяти (без записи на диск)
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let collection = CardCollection(context: viewContext)
        collection.name = "Sample Collection"
        
        let card1 = Card(context: viewContext)
        card1.frontText = "Front 1"
        card1.backText = "Back 1"
        card1.collection = collection
        
        let card2 = Card(context: viewContext)
        card2.frontText = "Front 2"
        card2.backText = "Back 2"
        card2.collection = collection
        
         do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        // Возвращаем готовый PersistenceController с тестовыми данными
        return result
    }()

    // Контейнер, хранит модель и управляет сохранением
    let container: NSPersistentContainer

    // Инициализатор: можно создать хранилище в памяти (для теста/превью) или на диске (для реального использования)
    init(inMemory: Bool = false) {
        // Создаем контейнер и указываем имя модели (должно совпадать с названием .xcdatamodeld файла)
        container = NSPersistentContainer(name: "Flash_Card")
        
        if inMemory {
            // Если работаем только в памяти — перенаправляем сохранение в "/dev/null"
            // Это значит, что данные не сохраняются на диск и исчезают после завершения работы
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Загружаем persistent stores (базу данных Core Data)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Настраиваем, чтобы контекст автоматически подхватывал изменения от других контекстов
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
