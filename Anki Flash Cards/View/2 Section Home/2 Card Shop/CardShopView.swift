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
            return shopCollections.shuffled()
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
                                    ShopCollectionCardView(collection: collection, vm: vm)
                                }
                            }
                        }
                    }
                }
            }
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
                    NavigationLink(destination: List_Crads_in_Shop_Language(collection: collection)) {
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
                        // Анимация нажатия
                        withAnimation(.easeInOut(duration: 0.3)) {
                            vm.isButtonPressed = true
                        }
                        
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        // Действие кнопки
                        addToUserCollections()
                        vm.isAddedLanguage = true
                        
                        // Возврат к исходному состоянию
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                vm.isButtonPressed = false
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#ddead1"))
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 43, height: 43)
                            .background(vm.isButtonPressed ? Color(hex: "#546a90") : Color(hex: "#546a90").opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 7)
                            )
                            .cornerRadius(12)
                            .scaleEffect(vm.isButtonPressed ? 0.4 : 1.0)
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
