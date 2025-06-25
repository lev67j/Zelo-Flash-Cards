//
//  MainSetCardView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import CoreData

struct MainSetCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    
    @State private var selectedCards: [Card]? = nil
    @State private var navigateToFlashCards = false
    @State private var selectedCardCount = 10
    
    
    // Sheets / Alerts
    @State private var showPicker = false
    @State private var open_sheet_flashcards = false
    @State private var open_sheet_edit_collection = false
    @State private var navigate_to_edit_set = false
    @State private var show_add_cards = false
    @State private var show_move_cards = false
    @State private var show_list_cards = false
    @State private var show_alert_cards_empty = false
    @State private var delete_set_alert = false
   
    
    
    var cards: [Card] {
        (collection.cards?.allObjects as? [Card]) ?? []
    }
    
    @State private var chartData: [(label: String, value: Int, color: Color)] = []
    
    // Design Settings
    @State private var back_for_base_button = Color(hex: "#546a50").opacity(0.1)
    @State private var back_for_main_start_button = Color(hex: "#546a50").opacity(0.7)
    @State private var text_color_for_base_button = Color(hex: "#546a50")
    @State private var text_color_for_sheet_edit_set = Color(hex: "#546a50")
    @State private var shadow_for_start_buttons: CGFloat = 10
   
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                VStack {
                    // Header: back button + settings collection button
                    VStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20)).bold()
                                    .foregroundStyle(Color(hex: "#546a50"))
                            }
                            
                            Spacer()
                            
                            // Edit Collection
                            VStack {
                                Button {
                                    open_sheet_edit_collection = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .sheet(isPresented: $open_sheet_edit_collection) {
                                    VStack {
                                        ZStack {
                                            Color(hex: "#ddead1")
                                                .ignoresSafeArea()
                                            
                                            // Action Buttons
                                            VStack {
                                                VStack(spacing: 35) {
                                                    
                                                    // Edit Set Button
                                                    VStack {
                                                        Button {
                                                            navigate_to_edit_set = true
                                                            open_sheet_edit_collection = false
                                                        } label: {
                                                            HStack {
                                                                Image(systemName: "pencil")
                                                                    .bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                Text("Edit Set")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                    
                                                    // Move Cards Button
                                                    VStack {
                                                        Button {
                                                            show_move_cards = true
                                                        } label: {
                                                            HStack {
                                                                Image(systemName: "arrowshape.turn.up.right")
                                                                    .bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                Text("Move Cards")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                        .sheet(isPresented: $show_move_cards) {
                                                            //    MoveCardsView(sourceCollection: collection)
                                                            VStack {
                                                                Text("")
                                                            }
                                                        }
                                                    }
                                                    
                                                    // Delete Button
                                                    VStack {
                                                        Button {
                                                            delete_set_alert = true
                                                        } label: {
                                                            HStack {
                                                                Image(systemName: "trash")
                                                                    .bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                Text("Delete Set")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(text_color_for_sheet_edit_set)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                    .alert(isPresented: $delete_set_alert) {
                                                        Alert(
                                                            title: Text("Delete Collection"),
                                                            message: Text("Are you sure you want to delete this collection and all its cards?"),
                                                            primaryButton: .destructive(Text("Delete")) {
                                                                deleteCollection()
                                                                open_sheet_edit_collection = false
                                                                dismiss()
                                                            },
                                                            secondaryButton: .cancel()
                                                        )
                                                    }
                                                }
                                                .padding(.top)
                                                .padding()
                                                Spacer()
                                                
                                            }
                                        }
                                        
                                    }
                                    .presentationDetents ([.height(200)])
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                     ScrollView {
                        VStack(spacing: 20) {
                            
                            // Statistic Bars
                            VStack {
                                BarChartView(data: chartData, back: back_for_base_button)
                                    .frame(height: 250)
                                    .padding(.horizontal)
                            }
                            
                            // Header for variants start buttons
                            VStack {
                                HStack {
                                    Text("\(collection.name ?? "Language")")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(text_color_for_base_button)
                                    
                                    Text("|")
                                        .font(.system(size: 20))
                                        .foregroundStyle(text_color_for_base_button.opacity(0.3))
                                    
                                    Text("\(collection.cards?.count ?? 0) cards")
                                        .font(.system(size: 16)).bold()
                                        .foregroundStyle(text_color_for_base_button)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            
                            // Variants Start Buttons
                            VStack(spacing: 10) {
                                
                                // Flash Cards
                                VStack {
                                       VStack {
                                            Button {
                                                // If Cards > 0
                                                if collection.cards?.count ?? 0 > 0 {
                                                    open_sheet_flashcards = true
                                                } else {
                                                    show_alert_cards_empty = true
                                                }
                                            } label: {
                                                HStack {
                                                    Text("Flash Cards")
                                                        .font(.headline)
                                                        .foregroundColor(text_color_for_base_button)
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(back_for_base_button)
                                                .cornerRadius(12)
                                            }
                                            .padding(.horizontal)
                                            .alert(isPresented: $show_alert_cards_empty) {
                                                Alert(
                                                    title: Text("No Cards"),
                                                    message: Text("Please add cards to start flashcards"),
                                                    dismissButton: .cancel()
                                                )
                                            }
                                            .sheet(isPresented: $open_sheet_flashcards) {
                                                ZStack {
                                                    Color(hex: "#ddead1")
                                                        .ignoresSafeArea()
                                                    
                                                    VStack {
                                                        VStack {
                                                            // Toggle Front and Back Sides
                                                            VStack {
                                                                HStack {
                                                                    Toggle(isOn: Binding(
                                                                        get: { collection.swapSides },
                                                                        set: { newValue in
                                                                            collection.swapSides = newValue
                                                                            try? viewContext.save()
                                                                        }
                                                                    )) {
                                                                        Text("Swap Front and Back Sides")
                                                                            .font(.headline)
                                                                            .foregroundColor(text_color_for_base_button)
                                                                    }
                                                                    .tint(Color(hex: "#546a50").opacity(0.5))
                                                                    .padding()
                                                                    .background(back_for_base_button)
                                                                    .cornerRadius(12)
                                                                }
                                                                .padding(.horizontal)
                                                            }
                                                            
                                                            // Start Custom Cards "5-10-15..."
                                                            VStack {
                                                                Button {
                                                                    showPicker = true
                                                                } label: {
                                                                    HStack {
                                                                        Text("Custom cards (\(selectedCardCount))")
                                                                            .font(.headline)
                                                                            .foregroundColor(text_color_for_base_button)
                                                                        Spacer()
                                                                    }
                                                                    .padding()
                                                                    .background(back_for_base_button)
                                                                    .cornerRadius(12)
                                                                }
                                                                .padding(.horizontal)
                                                                .sheet(isPresented: $showPicker) {
                                                                    ZStack {
                                                                        Color(hex: "#ddead1")
                                                                            .ignoresSafeArea()
                                                                        
                                                                        VStack {
                                                                            Text("Select number of cards")
                                                                                .font(.headline)
                                                                                .padding()
                                                                            
                                                                            Picker("Number of cards", selection: $selectedCardCount) {
                                                                                ForEach(Array(stride(from: 5, through: 1000, by: 5)), id: \.self) { number in
                                                                                    Text("\(number)").tag(number)
                                                                                }
                                                                            }
                                                                            .pickerStyle(.wheel)
                                                                            
                                                                            Button {
                                                                                let today = Calendar.current.startOfDay(for: Date())
                                                                                let dueCards = cards.filter { card in
                                                                                    if card.lastGrade == .again || card.isNew { return true }
                                                                                    if let scheduleDate = card.nextScheduleDate {
                                                                                        let scheduleDay = Calendar.current.startOfDay(for: scheduleDate)
                                                                                        return scheduleDay <= today
                                                                                    }
                                                                                    return false
                                                                                }
                                                                                selectedCards = Array(dueCards.shuffled().prefix(selectedCardCount))
                                                                                
                                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                                    navigateToFlashCards = true
                                                                                }
                                                                                
                                                                                // for dismiss sheet
                                                                                showPicker = false
                                                                                open_sheet_flashcards = false
                                                                            } label: {
                                                                                HStack {
                                                                                    Text("Start")
                                                                                        .font(.headline)
                                                                                        .foregroundColor(text_color_for_base_button)
                                                                                }
                                                                                .padding()
                                                                                .padding(.horizontal, 100)
                                                                                .background(back_for_main_start_button)
                                                                                .cornerRadius(12)
                                                                            }
                                                                        }
                                                                    }
                                                                    .presentationDetents([.height(300)])
                                                                }
                                                            }
                                                            
                                                            // Start Button
                                                            VStack {
                                                                Spacer()
                                                                
                                                                Button {
                                                                    selectedCards = cards
                                                                    
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                        navigateToFlashCards = true
                                                                    }
                                                                    
                                                                    // for dismiss sheet
                                                                    showPicker = false
                                                                    open_sheet_flashcards = false
                                                                } label: {
                                                                    HStack {
                                                                        Text("Start")
                                                                            .font(.headline)
                                                                            .foregroundColor(text_color_for_base_button)
                                                                    }
                                                                    .padding()
                                                                    .padding(.horizontal, 100)
                                                                    .background(back_for_main_start_button)
                                                                    .cornerRadius(12)
                                                                }
                                                                .padding(.horizontal)
                                                            }
                                                        }
                                                        .padding(.top)
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                .presentationDetents([.height(300)])
                                            }
                                        }
                                    
                                    
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: updateChartData) // Update columns
            .onChange(of: cards) {
                updateChartData()
            }
            .navigationDestination(isPresented: $navigateToFlashCards) {
                FlashCardViewTest(collection: collection, optionalCards: selectedCards)
                    .navigationBarBackButtonHidden(true)
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationDestination(isPresented: $navigate_to_edit_set) {
                EditSetView(collection: collection)
                    .environment(\.managedObjectContext, viewContext)
                    .navigationBarBackButtonHidden(true)
                
                
            }
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
    
    private func updateChartData() {
        chartData = CardGrade.allCases.map { grade in
            (
                label: grade.displayName,
                value: Dictionary(grouping: cards) { $0.lastGrade }[grade]?.count ?? 0,
                color: grade.color
            )
        }
    }
}

struct MainSetCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.swapSides = false
        
        // Add sample cards for preview
        for i in 0..<20 {
            let card = Card(context: context)
            card.creationDate = Date()
            card.lastGrade = CardGrade.allCases.randomElement()!
            card.isNew = i % 3 == 0
            card.nextScheduleDate = Calendar.current.date(byAdding: .day, value: i % 5, to: Date())
            collection.addToCards(card)
        }
        
        return MainSetCardView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}
