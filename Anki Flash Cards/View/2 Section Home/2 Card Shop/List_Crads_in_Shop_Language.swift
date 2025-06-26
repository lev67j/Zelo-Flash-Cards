//
//  List_Crads_in_Shop_Language.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-05-08.
//

import SwiftUI

struct List_Crads_in_Shop_Language: View {
    @ObservedObject var collection: ShopCollection
    @State private var searchText: String = ""
    
    private var cards: [ShopCard] {
        let allCards = (collection.cards?.allObjects as? [ShopCard]) ?? []
        let sortedCards = allCards.sorted { $0.creationDate ?? Date.distantPast > $1.creationDate ?? Date.distantPast }
        
        if searchText.isEmpty {
            return sortedCards
        } else {
            return sortedCards.filter { card in
                (card.frontText?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (card.backText?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                TextField("Search cards...", text: $searchText)
                    .padding(10)
                    .background(Color.white.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
                if cards.isEmpty {
                    Text("No cards available")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                   ScrollView {
                        VStack(spacing: 0) {
                            ForEach(cards) { card in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(card.frontText ?? "No front text")
                                            .font(.headline)
                                        Text(card.backText ?? "No back text")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                
                                if card != cards.last {
                                    Divider()
                                        .background(Color.gray)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(Color.white) // Фон для всего списка
                        .cornerRadius(12) // Закругленные углы для всего списка
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("\(collection.name ?? "Language") Cards")
            .onAppear {
                print("Loaded \(cards.count) cards for \(collection.name ?? "unknown")")
            }
        }
    }
}


struct LookShopCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create sample ShopCollection
        let collection = ShopCollection(context: context)
        collection.name = "Spanish"
        collection.priority = "middle"
        collection.creationDate = Date()
        
        // Add sample ShopCards
        for i in 1...5 {
            let card = ShopCard(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Date()
            card.collection = collection
        }
        
        return NavigationStack {
            List_Crads_in_Shop_Language(collection: collection)
                .environment(\.managedObjectContext, context)
        }
    }
}
