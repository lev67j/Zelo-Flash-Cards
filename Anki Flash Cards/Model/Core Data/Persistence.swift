//
//  Persistence.swift
//  Anki Flash Cards
//
//  Created by Lev Vlasov on 2025-05-30.
//
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем коллекцию и карточки для предпросмотра
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
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Flash_Card")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
