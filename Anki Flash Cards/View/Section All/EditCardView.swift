//
//  EditCardView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct EditCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var card: Card

    @State private var frontText: String
    @State private var backText: String
    @FocusState private var isFrontTextFocused: Bool

    init(card: Card) {
        self.card = card
        self._frontText = State(initialValue: card.frontText ?? "")
        self._backText = State(initialValue: card.backText ?? "")
    }

    var body: some View {
        ZStack {
            Color(hex: "#4A6C5A")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("Edit Card")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Front Text Field
                TextField("Front Text", text: $frontText)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .focused($isFrontTextFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFrontTextFocused = true
                        }
                    }
                
                // Back Text Field
                TextField("Back Text", text: $backText)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(frontText.isEmpty && backText.isEmpty ? Color.gray : Color(hex: "#E6A7FA")) // PINK HEX
                            .foregroundColor(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(frontText.isEmpty && backText.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }

    private func saveChanges() {
        card.frontText = frontText
        card.backText = backText
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving card: \(error)")
        }
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let card = Card(context: context)
        card.frontText = "Sample Front"
        card.backText = "Sample Back"
        card.creationDate = Date()
        return EditCardView(card: card)
            .environment(\.managedObjectContext, context)
    }
}
