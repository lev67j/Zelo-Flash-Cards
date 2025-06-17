//
//  StatisticsView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-09.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection

    @State private var selectedCards: [Card]? = nil
    @State private var navigateToFlashCards = false
    @State private var showPicker = false
    @State private var selectedCardCount = 10

    var cards: [Card] {
        (collection.cards?.allObjects as? [Card]) ?? []
    }
    
    @State private var chartData: [(label: String, value: Int, color: Color)] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#ddead1")
                .ignoresSafeArea()
           
                
                VStack(spacing: 20) {
                   BarChartView(data: chartData)
                    .frame(height: 250)
                    .padding(.horizontal)
                    
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
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                      
                    Button(action: {
                        selectedCards = cards
                        navigateToFlashCards = true
                    }) {
                        HStack {
                            Text("All cards")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Новая кнопка для выбора количества карточек
                    Button(action: {
                        showPicker = true
                    }) {
                        HStack {
                            Text("Custom cards (\(selectedCardCount))")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "play.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showPicker) {
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
                            
                            Button("Start Session") {
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
                                navigateToFlashCards = true
                                showPicker = false
                            }
                            .padding()
                            .background(Color(hex: "#E6A7FA")) // PINK HEX
                            .foregroundColor(.black)
                            .cornerRadius(12)
                        }
                        .presentationDetents([.medium])
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        selectedCards = nil
                        navigateToFlashCards = true
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.black)
                            Text("Start")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#E6A7FA")) // PINK HEX
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 2))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.white)
            .onAppear(perform: updateChartData) // Update columns
            .onChange(of: cards) { 
                updateChartData()
            }
            .navigationDestination(isPresented: $navigateToFlashCards) {
                FlashCardView(collection: collection, optionalCards: selectedCards)
                    .environment(\.managedObjectContext, viewContext)
            }
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

// Columns for level card
struct BarChartView: View {
    let data: [(label: String, value: Int, color: Color)]
    
    var maxValue: Int {
        data.map { $0.value }.max() ?? 1
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            ForEach(data, id: \.label) { item in
                let height: CGFloat = {
                    if maxValue > 0 {
                        return CGFloat(item.value) / CGFloat(maxValue) * 150
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
        .background(Color.white.opacity(0.3))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

struct StatisticsView_Previews: PreviewProvider {
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
        
        return StatisticsView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}
