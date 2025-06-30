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
    @ObservedObject private var vm = DesignVM()
    
    var body: some View {
        NavigationStack {
            ZStack {
                vm.color_back_mainset_view
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
                                    .foregroundStyle(vm.color_cancel_button_mainset)
                            }
                            
                            Spacer()
                            
                            // Edit Collection
                            VStack {
                                Button {
                                    open_sheet_edit_collection = true
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(vm.color_ellipsis_button_mainset)
                                }
                                .sheet(isPresented: $open_sheet_edit_collection) {
                                    VStack {
                                        ZStack {
                                            vm.color_back_sheet_edit_collection_mainset
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
                                                                    .foregroundColor(vm.color_pencil_sheet_edit_collection_mainset)
                                                                Text("Edit Set")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(vm.color_text_edit_set_sheet_edit_collection_mainset)
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
                                                                    .foregroundColor(vm.color_image_move_sheet_edit_collection_mainset)
                                                                Text("Move Cards")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(vm.color_text_move_sheet_edit_collection_mainset)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                        .sheet(isPresented: $show_move_cards) {
                                                          MoveCardsView(sourceCollection: collection)
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
                                                                    .foregroundColor(vm.color_image_trash_sheet_edit_collection_mainset)
                                                                Text("Delete Set")
                                                                    .font(.system(size: 17)).bold()
                                                                    .foregroundColor(vm.color_text_delete_sheet_edit_collection_mainset)
                                                                
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
                                BarChartView(data: chartData, back: vm.color_back_bar_chart_mainset)
                                    .frame(height: 250)
                                    .padding(.horizontal)
                            }
                            
                            // Header for variants start buttons
                            VStack {
                                HStack {
                                    Text("\(collection.name ?? "Language")")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(vm.color_language_name_mainset)
                                    
                                    Text("|")
                                        .font(.system(size: 20))
                                        .foregroundStyle(vm.color_line_mainset)
                                    
                                    Text("\(collection.cards?.count ?? 0) cards")
                                        .font(.system(size: 16)).bold()
                                        .foregroundStyle(vm.color_number_cards_mainset)
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
                                                    .foregroundColor(vm.color_text_flash_cards_button_mainset)
                                                Spacer()
                                            }
                                            .padding()
                                            .background(vm.color_back_flash_cards_button_mainset)
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
                                                vm.color_back_sheet_flash_card_mainset
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
                                                                        .foregroundColor(vm.color_text_toggle_front_back_sheet_flash_card_mainset)
                                                                }
                                                                .tint(vm.color_tint_toggle_front_back_sheet_flash_card_mainset)
                                                                .padding()
                                                                .background(vm.color_back_toggle_front_back_sheet_flash_card_mainset)
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
                                                                        .foregroundColor(vm.color_text_start_custom_cards_sheet_flash_card_mainset)
                                                                    Spacer()
                                                                }
                                                                .padding()
                                                                .background(vm.color_back_start_custom_cards_sheet_flash_card_mainset)
                                                                .cornerRadius(12)
                                                            }
                                                            .padding(.horizontal)
                                                            .sheet(isPresented: $showPicker) {
                                                                ZStack {
                                                                    vm.color_back_sheet_start_custom_cards_mainset
                                                                        .ignoresSafeArea()
                                                                    
                                                                    VStack {
                                                                        Text("Select number of cards")
                                                                            .foregroundStyle(vm.color_text_select_number_cards_mainset)
                                                                            .font(.headline)
                                                                            .padding()
                                                                        
                                                                        Picker("Number of cards", selection: $selectedCardCount) {
                                                                            ForEach(Array(stride(from: 5, through: 1000, by: 5)), id: \.self) { number in
                                                                                Text("\(number)")
                                                                                    .foregroundStyle(vm.color_text_number_cards_mainset)
                                                                                    .tag(number)
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
                                                                                    .foregroundColor(vm.color_text_button_start_mainset)
                                                                            }
                                                                            .padding()
                                                                            .padding(.horizontal, 100)
                                                                            .background(vm.color_back_button_start_mainset)
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
                                                                        .foregroundColor(vm.color_main_text_button_start_mainset)
                                                                }
                                                                .padding()
                                                                .padding(.horizontal, 100)
                                                                .background(vm.color_main_back_button_start_mainset)
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
                FlashCardView(collection: collection, optionalCards: selectedCards)
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

// Columns for level card
struct BarChartView: View {
    let data: [(label: String, value: Int, color: Color)]
    
    var maxValue: Int {
        data.map { $0.value }.max() ?? 1
    }
    
    let back: Color
    
    @ObservedObject private var vm = DesignVM()

    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            ForEach(data, id: \.label) { item in
                let height: CGFloat = {
                    if maxValue > 0 {
                        return CGFloat(item.value) / CGFloat(maxValue) * 130
                    } else {
                        return 150
                    }
                }()

                VStack {
                    Text("\(item.value)")
                        .font(.caption)
                        .foregroundColor(.black)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.color.opacity(0.7))
                        .frame(width: 50, height: height)

                    Text(item.label)
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(back)
        .cornerRadius(12)
    }
}
