//
//  AddCardView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import Foundation
import SwiftUI
import CoreData

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    
    @State private var frontText: String = ""
    @State private var backText: String = ""
    @State private var showJSONInput = false
    @State private var jsonText: String = ""

    struct CardData: Decodable {
        let front: String
        let back: String
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("Add New Card")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Input Fields or JSON Editor
                if showJSONInput {
                    TextEditor(text: $jsonText)
                        .frame(height: 200)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                } else {
                    // Front Text Field
                    TextField("Front Text", text: $frontText)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Back Text Field
                    TextField("Back Text", text: $backText)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Control Buttons
                HStack(spacing: 12) {
                    Button {
                        showJSONInput.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "doc.plaintext")
                                .foregroundColor(Color(hex: "#546a50"))
                            Text(showJSONInput ? "Manual Input" : "Import JSON")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                    // Add Card Button
                    Button {
                        if showJSONInput && !jsonText.isEmpty {
                            addCardsFromJSON()
                        } else {
                            addCard()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.black)
                            Text(showJSONInput ? "Add from JSON" : "Add Card")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background((showJSONInput && jsonText.isEmpty) || (!showJSONInput && frontText.isEmpty && backText.isEmpty) ? Color.gray.opacity(0.2) : Color(hex: "#546a50").opacity(0.5))
                        .cornerRadius(20)
                    }
                    .disabled((showJSONInput && jsonText.isEmpty) || (!showJSONInput && frontText.isEmpty && backText.isEmpty))
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    // Check if a card with the given frontText already exists in the collection
    private func cardExists(frontText: String) -> Bool {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "collection == %@ AND frontText == %@", collection, frontText)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking for existing card: \(error)")
            return false
        }
    }
    
    private func addCard() {
        // Skip if frontText is empty or card already exists
        guard !frontText.isEmpty else {
            print("Front text is empty, skipping card")
            return
        }
        guard !cardExists(frontText: frontText) else {
            print("Card with front text '\(frontText)' already exists, skipping")
            return
        }
        
        let newCard = Card(context: viewContext)
        newCard.frontText = frontText
        newCard.backText = backText
        newCard.collection = collection
        newCard.isNew = true
        newCard.creationDate = Date()
        
        do {
            try viewContext.save()
            frontText = ""
            backText = ""
        } catch {
            print("Error saving card: \(error)")
        }
    }

    private func addCardsFromJSON() {
        var added = false
        
        // Try JSON decoding first
        if let data = jsonText.data(using: .utf8) {
            do {
                let decoded = try JSONDecoder().decode([CardData].self, from: data)
                for entry in decoded {
                    // Skip if front text is empty or card already exists
                    guard !entry.front.isEmpty else {
                        print("Front text is empty for entry, skipping")
                        continue
                    }
                    guard !cardExists(frontText: entry.front) else {
                        print("Card with front text '\(entry.front)' already exists, skipping")
                        continue
                    }
                    
                    let card = Card(context: viewContext)
                    card.frontText = entry.front
                    card.backText = entry.back
                    card.collection = collection
                    card.isNew = true
                    card.creationDate = Date()
                    added = true
                }
            } catch {
                print("JSON parsing failed, trying alternative format: \(error)")
            }
        }
        
        // Fallback to line-by-line parsing
        let lines = jsonText.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: "-", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                let frontText = parts[0]
                // Skip if front text is empty or card already exists
                guard !frontText.isEmpty else {
                    print("Front text is empty for line, skipping")
                    continue
                }
                guard !cardExists(frontText: frontText) else {
                    print("Card with front text '\(frontText)' already exists, skipping")
                    continue
                }
                
                let card = Card(context: viewContext)
                card.frontText = frontText
                card.backText = parts[1]
                card.collection = collection
                card.isNew = true
                card.creationDate = Date()
                added = true
            }
        }

        // Save only if at least one unique card was added
        if added {
            do {
                try viewContext.save()
                jsonText = ""
                showJSONInput = false
            } catch {
                print("Error saving cards: \(error)")
            }
        } else {
            print("No unique cards were added")
        }
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Test Collection"
        return AddCardView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}
