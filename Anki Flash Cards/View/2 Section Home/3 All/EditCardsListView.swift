//
//  EditCardsListView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-11.
//

import SwiftUI

struct EditCardsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    @State private var searchText: String = ""
    @State private var showEditCardView: Bool = false
    @State private var cardToEdit: Card?
    @State private var showDeleteAlert: Bool = false
    @State private var cardToDelete: Card?

    private var cards: [Card] {
        let allCards = (collection.cards?.allObjects as? [Card]) ?? []
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
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
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
                                
                                Button {
                                    cardToEdit = card
                                    showEditCardView = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.horizontal)
                                
                                Button {
                                    cardToDelete = card
                                    showDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
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
                .navigationTitle("Edit Cards")
                .sheet(isPresented: $showEditCardView, onDismiss: {
                    cardToEdit = nil
                }) {
                    if let cardToEdit = cardToEdit {
                //        EditCardView(card: cardToEdit)
                 //           .environment(\.managedObjectContext, viewContext)
                    } else {
                        Text("Try Again Right Now. Please :)")
                            .foregroundColor(.green)
                    }
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Delete Card"),
                        message: Text("Are you sure you want to delete this card?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let card = cardToDelete {
                                deleteCard(card)
                            }
                            cardToDelete = nil
                        },
                        secondaryButton: .cancel(Text("Cancel")) {
                            cardToDelete = nil
                        }
                    )
                }
            }
        }
    }

    private func deleteCard(_ card: Card) {
        viewContext.delete(card)
        try? viewContext.save()
    }
}
struct EditCardsListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
      //  collection.title = "Sample Collection"
        
        // Add sample cards
        let card1 = Card(context: context)
        card1.frontText = "Question 1"
        card1.backText = "Answer 1"
        card1.creationDate = Date()
        let card2 = Card(context: context)
        card2.frontText = "Question 2"
        card2.backText = "Answer 2"
        card2.creationDate = Date().addingTimeInterval(-3600)
        collection.addToCards(card1)
        collection.addToCards(card2)
        
        return NavigationView {
            EditCardsListView(collection: collection)
                .environment(\.managedObjectContext, context)
        }
    }
}
