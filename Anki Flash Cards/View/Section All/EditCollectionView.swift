//
//  EditCollectionView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct EditCollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var collection: CardCollection

    @State private var collectionName: String
    @State private var selectedPriority: String
    @State private var showDeleteAlert = false

    init(collection: CardCollection) {
        self.collection = collection
        self._collectionName = State(initialValue: collection.name ?? "")
        self._selectedPriority = State(initialValue: collection.priority ?? "middle")
    }

    var body: some View {
          ZStack {
            Color(hex: "#4A6C5A")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("Edit Collection")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                // Name Field
                TextField("Collection Name", text: $collectionName)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Priority Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("Priority")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 10) {
                        PriorityButton(title: "Low", color: Color(hex: "#CDEDB3"), isSelected: selectedPriority == "low") {
                            selectedPriority = "low"
                        }
                        
                        PriorityButton(title: "Middle", color: Color(hex: "#CEF11B"), isSelected: selectedPriority == "middle") {
                            selectedPriority = "middle"
                        }
                        
                        PriorityButton(title: "High", color: Color(hex: "#1D6617"), isSelected: selectedPriority == "high") {
                            selectedPriority = "high"
                        }
                    }
                }
                .padding(.horizontal)
                
                // Actions
                VStack(spacing: 12) {
                    
                    // Add Cards Button
                    NavigationLink(destination: AddCardView(collection: collection)) {
                        HStack {
                            Image(systemName: "plus")
                                .bold()
                                .foregroundColor(.green)
                            Text("Add Cards")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Manage Cards Button
                    NavigationLink(destination: EditCardsListView(collection: collection)) {
                        HStack {
                            Image(systemName: "rectangle.stack.fill")
                                .foregroundColor(.blue)
                            Text("List Cards")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Move Cards Button
                    NavigationLink(destination: MoveCardsView(sourceCollection: collection)) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .foregroundColor(.orange)
                            Text("Move Cards")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    
                    // Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Delete Collection")
                                .font(.headline)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    saveCollection()
                }) {
                    Text("Save Changes")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#E6A7FA")) // PINK HEX
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Collection"),
                    message: Text("Are you sure you want to delete this collection and all its cards?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteCollection()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func saveCollection() {
        collection.name = collectionName
        collection.priority = selectedPriority

        do {
            try viewContext.save()
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func deleteCollection() {
        viewContext.delete(collection)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EditCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Sample Collection"
        collection.creationDate = Date()
        collection.priority = "middle"
        return EditCollectionView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}
