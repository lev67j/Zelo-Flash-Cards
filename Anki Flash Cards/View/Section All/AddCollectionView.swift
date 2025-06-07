//
//  AddCollectionView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct AddCollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName: String = ""
    @State private var selectedPriority: String = "middle"

    var body: some View {
        ZStack {
            Color(hex: "#4A6C5A")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text("New Collection")
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
                            .stroke(Color.black, lineWidth: 3)
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
                
                Spacer()
                
                // Save Button
                Button(action: {
                    addCollection()
                }) {
                    Text("Create Collection")
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
    
    private func addCollection() {
        let newCollection = CardCollection(context: viewContext)
        newCollection.name = collectionName
        newCollection.creationDate = Date()
        newCollection.priority = selectedPriority
        
        do {
            try viewContext.save()
            collectionName = ""
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// Custom Priority Button
struct PriorityButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 2)
                )
                .cornerRadius(20)
        }
    }
}

struct AddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCollectionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
