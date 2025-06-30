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
    
    @State private var add_name_alert = false

    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                // Title + Priority
                VStack(spacing: 15) {
                    // Name Field
                    VStack {
                        TextField("Collection Name", text: $collectionName)
                            .padding(.horizontal)
                            .foregroundStyle(Color(hex: "#546a50"))
                        
                        Rectangle()
                            .foregroundStyle(Color(hex: "#546a50"))
                            .frame(height: 1.3)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Title")
                                .foregroundStyle(Color(hex: "#546a50"))
                                .font(.system(size: 13))
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                    .padding(.bottom, 25)
                    
                    // Priority Selection
                    VStack {
                        HStack {
                            VStack {
                                HStack {
                                    Text("Priority")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Rectangle()
                                        .foregroundStyle(Color(hex: "#546a50").opacity(0.3))
                                        .frame(width: 1.5, height: 20)
                                    
                                    HStack(spacing: 10) {
                                        PriorityButton(title: "Low", color: Color(hex: "d4d0b9"), isSelected: selectedPriority == "low") {
                                            selectedPriority = "low"
                                        }
                                        
                                        PriorityButton(title: "Middle", color: Color(hex: "9ea99c"), isSelected: selectedPriority == "middle") {
                                            selectedPriority = "middle"
                                        }
                                        
                                        PriorityButton(title: "High", color: Color(hex: "90997f"), isSelected: selectedPriority == "high") {
                                            selectedPriority = "high"
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    }
                }
                .padding(.top, 30)
                
                Spacer()
                
                VStack {
                    Button {
                        if collectionName != "" && collectionName != " " && collectionName != "  " {
                            addCollection()
                        } else {
                            add_name_alert = true
                        }
                    } label: {
                        Text("Create Collection")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "FBDA4B"))
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
           .alert(isPresented: $add_name_alert) {
                Alert(
                    title: Text("Please add name"),
                    message: Text(""),
                    dismissButton: .cancel()
                )
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

struct AddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCollectionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
