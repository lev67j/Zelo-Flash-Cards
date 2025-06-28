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
            Color(hex: "#ddead1")
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
                    Text("Select a collection for transfer")
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
                                        .background(moveTarget == target ? Color(hex: "#546a50") : Color.gray.opacity(0.2))
                                        .foregroundColor(moveTarget == target ? .white : .black)
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
                                .foregroundColor(Color(hex: "#E6A7FA")) // PINK HEX
                            
                            Text(selectedCards.count == cards.count ? "Remove selection" : "Select all cards")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                       .cornerRadius(20)
                    }
                    
                    Button(action: {
                        isCopyMode = false
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .foregroundColor(Color(hex: "#E6A7FA")) // PINK HEX
                            
                            Text("Move")
                                .font(.subheadline)
                                .foregroundColor(isCopyMode ? .black : .white)
                        }
                        .frame(width: 70, height: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isCopyMode ? Color.gray.opacity(0.2) : Color(hex: "#546a50"))
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        isCopyMode = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                                .foregroundColor(Color(hex: "#E6A7FA")) // PINK HEX
                            
                            Text("Copy")
                                .font(.subheadline)
                                .foregroundColor(isCopyMode ? .white : .black)
                        }
                        .frame(width: 70, height: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isCopyMode ? Color(hex: "#546a50") : Color.gray.opacity(0.2))
                       .cornerRadius(20)
                    }
                }
                
                // Список карточек
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(cards, id: \.self) { card in
                            VStack {
                                HStack {
                                    // Cell Card
                                    VStack(alignment: .leading) {
                                        // Front
                                        VStack {
                                            HStack {
                                                Text(card.frontText ?? "No text")
                                                    .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                    .font(.system(size: 17))
                                                    .padding(.horizontal)
                                                
                                                Spacer()
                                            }
                                            
                                            Rectangle()
                                                .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                .frame(height: 1.3)
                                                .padding(.horizontal)
                                            
                                            HStack {
                                                Text("Term")
                                                    .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                    .font(.system(size: 11))
                                                    .padding(.horizontal)
                                                
                                                Spacer()
                                            }
                                        }
                                        .padding(.bottom, 10)
                                        
                                        // Back
                                        VStack {
                                            HStack {
                                                Text(card.backText ?? "No text")
                                                    .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                    .font(.system(size: 17))
                                                    .padding(.horizontal)
                                                
                                                Spacer()
                                            }
                                            
                                            Rectangle()
                                                .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                .frame(height: 1.3)
                                                .padding(.horizontal)
                                            
                                            HStack {
                                                Text("Definition")
                                                    .foregroundStyle(selectedCards.contains(card) ? Color(hex: "#546a50") : Color.gray.opacity(0.7))
                                                    .font(.system(size: 11))
                                                    .padding(.horizontal)
                                                
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                .frame(height: 150)
                                .background(selectedCards.contains(card) ?
                                            Color(hex: "#546a50").opacity(0.2) :
                                                Color.gray.opacity(0.2))
                                .onTapGesture {
                                    toggleSelection(for: card)
                                }
                            }
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
                        .background(moveTarget == nil || selectedCards.isEmpty ? Color.gray.opacity(0.2) : Color(hex: "#546a50").opacity(0.6)) // PINK HEX
                        .foregroundColor(.black)
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
