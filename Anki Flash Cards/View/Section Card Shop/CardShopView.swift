//
//  CardShopView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-05-08.
//

import SwiftUI
import CoreData

struct CardShopView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ShopCollection.priority, ascending: false),
            NSSortDescriptor(keyPath: \ShopCollection.name, ascending: true)
        ],
        animation: .default)
    private var shopCollections: FetchedResults<ShopCollection>
    
    @ObservedObject private var vm = ShopVM()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(shopCollections) { collection in
                            ShopCollectionCardView(collection: collection, vm: vm)
                        }
                    }
                }
                .onAppear {
                    initializeShopCollections()
                }
            }
        }
    }

    private func initializeShopCollections() {
        let languages = [
            "Spanish", "English", "French", "German", "Chinese",
            "Japanese", "Russian", "Italian", "Portuguese", "Arabic"
        ]
        
        let fetchRequest: NSFetchRequest<ShopCollection> = ShopCollection.fetchRequest()
        do {
            let existingCollections = try viewContext.fetch(fetchRequest)
            let existingNames = Set(existingCollections.map { $0.name ?? "" })
            
            for language in languages where !existingNames.contains(language) {
                let newCollection = ShopCollection(context: viewContext)
                newCollection.name = language
                newCollection.priority = "middle"
                newCollection.creationDate = Date()
                
                // Download card from JSON
                loadCardsFromJSON(for: newCollection)
                
                print(newCollection.cards?.count ?? 0)
            }
            try viewContext.save()
        } catch {
            print("Ошибка при инициализации магазинных коллекций: \(error)")
        }
    }
    private func loadCardsFromJSON(for collection: ShopCollection) {
        guard let language = collection.name else { return }
        
        // Загрузка JSON-файла из бандла
        guard let url = Bundle.main.url(forResource: language, withExtension: "json") else {
            print("JSON-файл для \(language) не найден")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let cardData = try decoder.decode([CardData].self, from: data)
            
            // Создание ShopCard для каждой записи
            for cardEntry in cardData {
                let card = ShopCard(context: viewContext)
                card.frontText = cardEntry.front
                card.backText = cardEntry.back
                card.creationDate = Date()
                card.collection = collection
            }
        } catch {
            print("Ошибка при загрузке карточек для \(language): \(error)")
        }
    }
}

struct ShopCollectionCardView: View {
    @ObservedObject var collection: ShopCollection
    @ObservedObject var vm: ShopVM
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
          
            VStack(alignment: .leading) {
                Text(collection.name ?? "Language")
                    .font(.title3)
                    .foregroundColor(.black)
                    .padding(.bottom, 70)
                
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    
                    Text("2025")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .background(Color(hex: "#546a50").opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 8)
            )
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: LookShopCardView(collection: collection)) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                            .bold()
                            .padding(10)
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.trailing, 25)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        addToUserCollections()
                        vm.isAddedLanguage = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#ddead1"))
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 43, height: 43)
                            .background(Color(hex: "#546a90").opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 7)
                            )
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.bottom, 15)
            .padding(.trailing, 25)
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func priorityColor(for priority: String) -> Color {
        switch priority.lowercased() {
        case "low":
            return Color.blue
        case "middle":
            return Color.orange
        case "high":
            return Color.red
        default:
            return Color.gray
        }
    }
    
    private func addToUserCollections() {
        let userCollection = CardCollection(context: viewContext)
        userCollection.name = collection.name
        userCollection.priority = collection.priority
        userCollection.creationDate = Date()
        
        // Копирование карточек из ShopCard в Card
        if let shopCards = collection.cards?.allObjects as? [ShopCard] {
            for shopCard in shopCards {
                let userCard = Card(context: viewContext)
                userCard.frontText = shopCard.frontText
                userCard.backText = shopCard.backText
                userCard.creationDate = shopCard.creationDate
                userCard.collection = userCollection
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Ошибка при добавлении коллекции в пользовательские: \(error)")
        }
    }
}

// Структура для декодирования JSON
struct CardData: Decodable {
    let front: String
    let back: String
}
