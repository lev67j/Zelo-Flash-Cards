//
//  EditSetView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-22.
//

import SwiftUI

struct EditSetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var collection: CardCollection

    @State private var collectionName: String
    @State private var selectedPriority: String
 
    init(collection: CardCollection) {
        self.collection = collection
        self._collectionName = State(initialValue: collection.name ?? "")
        self._selectedPriority = State(initialValue: collection.priority ?? "middle")
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            
            VStack(spacing: 30) {
                // Name Field
                VStack {
                    TextField("Collection Name", text: $collectionName)
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Priority Selection
                VStack {
                    HStack {
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
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
                    
                // Save Button
                VStack {
                    Button {
                        saveCollection()
                    } label: {
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
}

struct EditSetView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Sample Collection"
        collection.creationDate = Date()
        collection.priority = "middle"
        return EditSetView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}

