//
//  MoveCardsView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-11.
//

import SwiftUI
import CoreData

struct MoveCardsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var sourceCollection: CardCollection
    @FetchRequest(entity: CardCollection.entity(), sortDescriptors: [])
    private var allCollections: FetchedResults<CardCollection>

    @State private var selectedCards: Set<Card> = []
    @State private var moveTarget: CardCollection?
    @State private var isCopyMode: Bool = false

    private var cards: [Card] {
        (sourceCollection.cards as? Set<Card>)?.sorted { ($0.frontText ?? "") < ($1.frontText ?? "") } ?? []
    }

    var body: some View {
        ZStack {
            Color(hex: "#4A6C5A")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок
                Text("Transferring cards")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Выбор целевой коллекции
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a collection")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(allCollections.filter { $0 != sourceCollection }) { target in
                                Button(action: {
                                    moveTarget = target
                                }) {
                                    Text(target.name ?? "Untitled")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(moveTarget == target ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(moveTarget == target ? .white : .black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Кнопки управления
                HStack(spacing: 12) {
                    Button(action: {
                        if selectedCards.count == cards.count {
                            selectedCards.removeAll()
                        } else {
                            selectedCards = Set(cards)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedCards.count == cards.count ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                            Text(selectedCards.count == cards.count ? "Remove selection" : "Select all")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        isCopyMode.toggle()
                    }) {
                        HStack {
                            Image(systemName: isCopyMode ? "doc.on.doc.fill" : "arrowshape.turn.up.right")
                                .foregroundColor(.orange)
                            Text(isCopyMode ? "Copy" : "Move")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                
                // Список карточек
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(cards, id: \.self) { card in
                            HStack {
                                Text(card.frontText ?? "No text")
                                    .font(.body)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: selectedCards.contains(card) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.blue)
                                    .onTapGesture {
                                        toggleSelection(for: card)
                                    }
                            }
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Кнопка действия
                Button(action: {
                    if let target = moveTarget {
                        moveOrCopyCards(to: target)
                    }
                }) {
                    Text(moveButtonTitle)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(moveTarget == nil || selectedCards.isEmpty ? Color.gray : Color(hex: "#E6A7FA")) // PINK HEX
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                .disabled(moveTarget == nil || selectedCards.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private var moveButtonTitle: String {
        isCopyMode ? "Copy cards" : "Move cards"
    }

    private func toggleSelection(for card: Card) {
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else {
            selectedCards.insert(card)
        }
    }

    private func moveOrCopyCards(to target: CardCollection) {
        for card in selectedCards {
            if isCopyMode {
                let newCard = Card(context: viewContext)
                newCard.frontText = card.frontText
                newCard.backText = card.backText
                newCard.creationDate = card.creationDate
                newCard.collection = target
            } else {
                card.collection = target
            }
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error while moving/copying: \(error)")
        }
    }
}

struct MoveCardsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Test collection"
        return MoveCardsView(sourceCollection: collection)
            .environment(\.managedObjectContext, context)
    }
}
