//
//  CardShopView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-05-08.
//

import SwiftUI
import CoreData

struct CardShopView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ShopCollection.priority, ascending: false),
            NSSortDescriptor(keyPath: \ShopCollection.name, ascending: true)
        ],
        animation: .default)
    private var shopCollections: FetchedResults<ShopCollection>
    
    @ObservedObject private var vm = ShopVM()
    @State private var searchText: String = ""
    
    // Computed property to sort collections by priority
    private var sorted_shop_collections: [ShopCollection] {
        if searchText.isEmpty {
            return shopCollections.dropLast(0)
        } else {
            return shopCollections.filter { collection in
                (collection.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (collection.language?.name_language?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                VStack {
                    // Search Language
                    VStack(alignment: .leading) {
                        HStack {
                            // Search
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(.gray.opacity(0.20))
                                        .frame(height: 50)
                                        .cornerRadius(30)
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            HStack {
                                                Image(systemName: "magnifyingglass")
                                                    .foregroundStyle(.black.opacity(0.41))
                                                    .bold()
                                                
                                                TextField("Search Language", text: $searchText)
                                                    .foregroundStyle(.black.opacity(0.41))
                                                    .bold()
                                            }
                                            .padding(.leading)
                                            
                                            Spacer()
                                            
                                        }
                                    }
                                }
                                .padding(.leading, 10)
                                
                            }
                            
                            // Cancel
                            VStack {
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Cancel")
                                        .font(.system(size: 16)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 7)
                            }
                            
                        }
                        .padding(5)
                    }
                    
                    // List Collections
                    VStack {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(sorted_shop_collections) { collection in
                                     NavigationLink {
                                         List_Crads_in_Shop_Language(collection: collection)
                                             .navigationBarBackButtonHidden(true)
                                    } label: {
                                        ShopCollectionCardView(collection: collection, vm: vm)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    // Вибрация
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()
                }
            }
        }
    }
}

struct ShopCollectionCardView: View {
    @ObservedObject var collection: ShopCollection
    @ObservedObject var vm: ShopVM
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(spacing: 3) {
                    HStack {
                        Text(collection.name ?? "Language")
                            .font(.title3)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(hex: "#546a50").opacity(0.3))
                    
                    HStack {
                        Text("\(collection.cards?.count ?? 0) words")
                            .foregroundColor(Color(hex: "#546a50").opacity(0.5))
                            .font(.system(size: 17))
                        
                        Spacer()
                    }
                }
                .padding(.bottom, 40)
                
                
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
            .background(Color(hex: "#546a50").opacity(0.000000001))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 8)
            )
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        // Действие кнопки
                        withAnimation(.easeInOut(duration: 0.3)) {
                            addToUserCollections()
                            vm.isAddedLanguage = true
                            dismiss()
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 43, height: 43)
                            .background(Color(hex: "FBDA4B"))
                            .cornerRadius(12)
                            .scaleEffect(1.0)
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
