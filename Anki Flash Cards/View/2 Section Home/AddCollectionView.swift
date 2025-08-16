//
//  AddCollectionView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

struct AddCollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName: String = ""
    @State private var selectedPriority: Int64 = 50
    
    @State private var add_name_alert = false
    
    @State private var screenEnterTime: Date?

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
                            .onChange(of: collectionName) { newValue in
                                Analytics.logEvent("add_collection_name_changed", parameters: [
                                    "new_name": newValue
                                ])
                            }
                        
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
                                        PriorityButton(title: "Low", color: Color(hex: "d4d0b9"), isSelected: selectedPriority == 20) {
                                            selectedPriority = 20
                                            Analytics.logEvent("add_collection_priority_selected", parameters: [
                                                "priority": "Low"
                                            ])
                                        }
                                        
                                        PriorityButton(title: "Middle", color: Color(hex: "9ea99c"), isSelected: selectedPriority == 50) {
                                            selectedPriority = 50
                                            Analytics.logEvent("add_collection_priority_selected", parameters: [
                                                "priority": "Middle"
                                            ])
                                        }
                                        
                                        PriorityButton(title: "High", color: Color(hex: "90997f"), isSelected: selectedPriority == 100) {
                                            selectedPriority = 100
                                            Analytics.logEvent("add_collection_priority_selected", parameters: [
                                                "priority": "High"
                                            ])
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
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        Analytics.logEvent("add_collection_create_button_tap", parameters: [
                            "name": collectionName,
                            "priority": selectedPriority
                        ])
                        
                        if collectionName.trimmingCharacters(in: .whitespaces).isEmpty {
                            add_name_alert = true
                        } else {
                            addCollection()
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
                    dismissButton: .cancel({
                        Analytics.logEvent("add_collection_alert_shown", parameters: nil)
                    })
                )
            }
        }
        .onAppear {
            screenEnterTime = Date()
            Analytics.logEvent("add_collection_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("add_collection_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
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
            Analytics.logEvent("add_collection_saved", parameters: [
                "name": collectionName,
                "priority": selectedPriority
            ])
            collectionName = ""
            dismiss()
        } catch {
            let nsError = error as NSError
            Analytics.logEvent("add_collection_save_error", parameters: [
                "error": nsError.localizedDescription
            ])
        }
    }
}

struct AddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddCollectionView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
               .cornerRadius(20)
        }
    }
}

