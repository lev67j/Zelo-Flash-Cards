//
//  FlashCardView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct FlashCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection

    var optionalCards: [Card]?

    @State private var currentCardIndex: Int = 0
    @State private var showBackSide: Bool = false
    @State private var userInput: String = ""
    @State private var sessionCards: [Card] = []
    @State private var cardsSeen: Int = 0
    @State private var totalCards: Int = 0
    @State private var allCards: [Card] = []

    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
            .ignoresSafeArea()
   
        VStack {
            if totalCards == 0 {
                // No Cards To Review
                
                // Header
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
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                }
                
                VStack {
                    Spacer()
                    Text("No cards to review!")
                        .font(.system(size: 30).bold())
                        .foregroundColor(.black)
                        .padding()
                    
                    if !allCards.isEmpty {
                        Button(action: {
                            sessionCards = allCards
                            currentCardIndex = 0
                            cardsSeen = 0
                            totalCards = sessionCards.count
                            print("Repeat all cards button pressed, sessionCards count: \(sessionCards.count)")
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.green)
                                Text("Repeat all cards")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(12)
                        }
                    } else {
                        Text("(No cards available in collection.)")
                            .font(.system(size: 20).bold())
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
            } else {
                
                // Header
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
                        
                        Button {
                            nextCard()
                        } label: {
                            HStack(spacing: 4) {
                                Text("Skip")
                                    .font(.system(size: 17)).bold()
                                    .foregroundStyle(Color(hex: "#546a50"))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 20)).bold()
                                    .foregroundStyle(Color(hex: "#546a50"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                
                // Main Content
                VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("\(cardsSeen) / \(cardsSeen + sessionCards.count)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    
                    ZStack {
                        ProgressView(value: Float(cardsSeen), total: Float(cardsSeen + sessionCards.count))
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(height: 14)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                if let card = sessionCards.isEmpty ? nil : sessionCards[currentCardIndex] {
                    // Determine which text to show based on swapSides and showBackSide
                    let frontText = collection.swapSides ? card.backText ?? "" : card.frontText ?? ""
                    let backText = collection.swapSides ? card.frontText ?? "" : card.backText ?? ""
                    
                    Text(showBackSide ? backText : frontText)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            withAnimation {
                                showBackSide.toggle()
                            }
                        }
                    
                    TextField("Enter your translation...", text: $userInput)
                        .padding()
                        .background(Color.white.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    HStack(spacing: 8) {
                        GradientButton(
                            title: "Again",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.8), Color(red: 1.0, green: 0.7, blue: 0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { handleAgain(card) }
                        )
                        GradientButton(
                            title: "Hard",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 1.0, green: 0.9, blue: 0.7), Color(red: 1.0, green: 0.85, blue: 0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { handleHard(card) }
                        )
                        GradientButton(
                            title: "Good",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.8, green: 1.0, blue: 0.8), Color(red: 0.7, green: 0.95, blue: 0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { handleGood(card) }
                        )
                        GradientButton(
                            title: "Easy",
                            gradient: LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.8, green: 0.9, blue: 1.0), Color(red: 0.7, green: 0.85, blue: 1.0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            action: { handleEasy(card) }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            }
        }
        .onAppear {
            prepareSession()
        }
    }
    }
}

// MARK: - Логика работы повторения (Spaced Repetition)
extension FlashCardView {
    private func nextScheduleDateForHard() -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: 30, to: Date())!
    }
    
    private func nextScheduleDateForGood() -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        return calendar.date(byAdding: .minute, value: 1, to: startOfTomorrow)!
    }
    
    private func nextScheduleDateForEasy() -> Date {
        let calendar = Calendar.current
        let fourDaysLater = calendar.date(byAdding: .day, value: 4, to: Date())!
        return calendar.startOfDay(for: fourDaysLater)
    }
  
    private func prepareSession() {
        allCards = (collection.cards?.allObjects as? [Card]) ?? []
        print("Prepare session: allCards count = \(allCards.count), optionalCards count = \(optionalCards?.count ?? 0)")
        
        // Определяем приоритеты
        let gradePriority: [CardGrade: Int] = [.new: 0, .again: 1, .hard: 2, .good: 3, .easy: 4]
        
        // Если переданы optionalCards, сортируем их
        sessionCards = optionalCards ?? []
        if sessionCards.isEmpty && optionalCards == nil {
            let today = Calendar.current.startOfDay(for: Date())
            let dueCards = allCards.filter { card in
                print("Filtering card \(card.frontText ?? "unknown"): isNew=\(card.isNew), lastGrade=\(card.lastGrade.rawValue), nextScheduleDate=\(String(describing: card.nextScheduleDate))")
                if card.isNew && card.lastGrade == .new {
                    return true
                }
                switch card.lastGrade {
                case .again:
                    return true
                case .hard:
                    return card.nextScheduleDate.map { $0 <= Date() } ?? false
                case .good, .easy:
                    return card.nextScheduleDate.map { Calendar.current.startOfDay(for: $0) <= today } ?? false
                default:
                    return false
                }
            }
            
            sessionCards = dueCards.sorted { card1, card2 in
                let priority1 = gradePriority[card1.lastGrade] ?? 5
                let priority2 = gradePriority[card2.lastGrade] ?? 5
                print("Sorting: \(card1.frontText ?? "unknown") (priority \(priority1)) vs \(card2.frontText ?? "unknown") (priority \(priority2))")
                return priority1 < priority2
            }
            print("Using filtered and sorted dueCards for session, sessionCards count = \(sessionCards.count)")
        } else {
            // Сортируем optionalCards по приоритету
            sessionCards.sort { card1, card2 in
                let priority1 = gradePriority[card1.lastGrade] ?? 5
                let priority2 = gradePriority[card2.lastGrade] ?? 5
                print("Sorting optionalCards: \(card1.frontText ?? "unknown") (priority \(priority1)) vs \(card2.frontText ?? "unknown") (priority \(priority2))")
                return priority1 < priority2
            }
            print("Using sorted optionalCards for session, sessionCards count = \(sessionCards.count)")
        }
        
        cardsSeen = 0
        totalCards = sessionCards.count
        currentCardIndex = 0
        showBackSide = false
        userInput = ""
        print("Session prepared: totalCards = \(totalCards)")
    }
    
    private func nextCard() {
        if sessionCards.isEmpty { return }
        if currentCardIndex < sessionCards.count - 1 {
            currentCardIndex += 1
        } else {
            currentCardIndex = 0
        }
        showBackSide = false
        userInput = ""
    }
    
    private func handleAgain(_ card: Card) {
        card.lastGrade = .again
        card.isNew = false
        saveCard(card)
        let index = currentCardIndex
        let removed = sessionCards.remove(at: index)
        sessionCards.append(removed)
        currentCardIndex = (currentCardIndex >= sessionCards.count) ? 0 : currentCardIndex
        totalCards = cardsSeen + sessionCards.count
        nextCard()
    }
    
    private func handleHard(_ card: Card) {
        card.nextScheduleDate = nextScheduleDateForHard()
        card.lastGrade = .hard
        card.isNew = false
        saveCard(card)
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        if sessionCards.isEmpty {
            totalCards = cardsSeen
        } else {
            currentCardIndex = (currentCardIndex >= sessionCards.count) ? 0 : currentCardIndex
            nextCard()
        }
    }
    
    private func handleGood(_ card: Card) {
        card.nextScheduleDate = nextScheduleDateForGood()
        card.lastGrade = .good
        card.isNew = false
        saveCard(card)
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        if sessionCards.isEmpty {
            totalCards = cardsSeen
        } else {
            currentCardIndex = (currentCardIndex >= sessionCards.count) ? 0 : currentCardIndex
            nextCard()
        }
    }
    
    private func handleEasy(_ card: Card) {
        card.nextScheduleDate = nextScheduleDateForEasy()
        card.lastGrade = .easy
        card.isNew = false
        saveCard(card)
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        if sessionCards.isEmpty {
            totalCards = cardsSeen
        } else {
            currentCardIndex = (currentCardIndex >= sessionCards.count) ? 0 : currentCardIndex
            nextCard()
        }
    }
    
    private func saveCard(_ card: Card) {
        do {
            try viewContext.save()
        } catch {
            print("Error saving card: \(error)")
        }
    }
}

struct GradientButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(gradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
                .cornerRadius(12)
        }
    }
}

struct FlashCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Test Collection"
        
        // Добавляем тестовые карточки
      /*  for i in 1...3 {
            let card = Card(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Calendar.current.startOfDay(for: Date())
            card.isNew = true
            collection.addToCards(card)
        }*/
        try? context.save()
        
        return FlashCardView(collection: collection, optionalCards: (collection.cards?.allObjects as? [Card]))
            .environment(\.managedObjectContext, context)
    }
}
