//
//  FlashCardViewTest.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-23.
//

import SwiftUI
import CoreData

struct FlashCardViewTest: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    
    var optionalCards: [Card]?
    
    @State private var currentCardIndex: Int = 0
    @State private var sessionCards: [Card] = []
    @State private var cardsSeen: Int = 0
    @State private var totalCards: Int = 0
    @State private var allCards: [Card] = []
    @State private var showNoCardsView = false
    
    @State private var hard_cards: Int = 0
    @State private var good_cards: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                if showNoCardsView {
                    
                    // Finish Session
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
                                showNoCardsView = false
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
                    // Main Content
                    VStack(spacing: 20) {
                        
                        // Header
                        VStack {
                            // buttons + progress
                            VStack(spacing: 10) {
                                
                                HStack {
                                    Button {
                                        dismiss()
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 20)).bold()
                                            .foregroundStyle(Color(hex: "#546a50"))
                                    }
                                    .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    Text("\(cardsSeen) / \(cardsSeen + sessionCards.count)")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Button {
                                        //dismiss()
                                    } label: {
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 20)).bold()
                                            .foregroundStyle(Color(hex: "#546a50"))
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.bottom, 10)
                                .padding(.top, 5)
                                
                                ZStack {
                                    ProgressView(value: Float(cardsSeen), total: Float(cardsSeen + sessionCards.count))
                                        .progressViewStyle(LinearProgressViewStyle())
                                        .frame(height: 5)
                                }
                                .padding(.horizontal)
                            }
                            
                            
                            // 18 hard | 36 good
                            VStack {
                                
                                HStack {
                                    Text("\(hard_cards)")
                                        .background(
                                            Rectangle()
                                                .fill(.orange)
                                                .frame(width: 45, height: 30)
                                          )
                                    
                                    Spacer()
                                    
                                    Text("\(good_cards)")
                                        .background(
                                            Rectangle()
                                                .fill(.green)
                                                .frame(width: 45, height: 30)
                                          )
                                }
                                .padding(.top, 25)
                                .padding(.horizontal, 15)
                            }
                            .padding(.bottom, 30)
                        }
                        // Card stack
                        if !sessionCards.isEmpty {
                            ZStack {
                                ForEach(Array(sessionCards.enumerated().prefix(3)), id: \.element) { (index, card) in
                                    let isTop = index == currentCardIndex
                                    
                                    CardView(
                                        card: card,
                                        collection: collection,
                                        isTop: isTop,
                                        onSwiped: { direction in
                                            handleSwipe(for: card, direction: direction)
                                        }
                                    )
                                    .stacked(at: index - currentCardIndex, in: min(3, sessionCards.count - currentCardIndex))
                                    .zIndex(Double(sessionCards.count - index))
                                    .allowsHitTesting(isTop)
                                }
                            }
                            .frame(height: 400)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                prepareSession()
                showNoCardsView = sessionCards.isEmpty && totalCards == 0
            }
            .onChange(of: sessionCards) { _ in
                if sessionCards.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNoCardsView = true
                    }
                }
            }
        }
    }
   private func handleSwipe(for card: Card, direction: SwipeDirection) {
        switch direction {
        case .left:
            handleHard(card)
        case .right:
            handleGood(card)
        }
    }
    
    enum SwipeDirection {
        case left, right
    }
}

// MARK: - Draggable Card View
struct CardView: View {
    let card: Card
    let collection: CardCollection
    let isTop: Bool
    let onSwiped: (FlashCardViewTest.SwipeDirection) -> Void
    
    @State private var flipped = false
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    private var cardBackgroundColor: Color {
        if offset.width > 0 {
            // Свайп вправо - зеленый
            return Color.green
        } else if offset.width < 0 {
            // Свайп влево - красный
            return Color.orange
        } else {
            // Нейтральное положение - белый
            return Color.white
        }
    }
  
    var body: some View {
        let swapSides = collection.swapSides
        let frontText = swapSides ? (card.backText ?? "") : (card.frontText ?? "")
        let backText = swapSides ? (card.frontText ?? "") : (card.backText ?? "")
        let displayText = flipped ? backText : frontText
        
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white) // Используем вычисляемое свойство для цвета
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardBackgroundColor, lineWidth: 2)
                    )
                    .frame(width: 350, height: 470)
                
                
                if offset.width > 0 {
                    // Свайп вправо - зеленый
                    Text("Know")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(cardBackgroundColor)
                        .padding()
                } else if offset.width < 0 {
                    // Свайп влево - красный
                    Text("Still learning")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(cardBackgroundColor)
                        .padding()
                } else {
                    // Нейтральное положение - белый
                    Text(displayText)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                isTop ? DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                    }
                    .onEnded { gesture in
                        let horizontal = gesture.translation.width
                        let threshold: CGFloat = 100
                        
                        if abs(horizontal) > threshold {
                            let direction: FlashCardViewTest.SwipeDirection = horizontal > 0 ? .right : .left
                            
                            withAnimation(.easeOut) {
                                switch direction {
                                case .left:
                                    offset = CGSize(width: -500, height: 0)
                                    rotation = -20
                                case .right:
                                    offset = CGSize(width: 500, height: 0)
                                    rotation = 20
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwiped(direction)
                            }
                        } else {
                            withAnimation(.spring()) {
                                offset = .zero
                                rotation = 0
                            }
                        }
                    }
                : nil
            )
            .onTapGesture {
                if isTop {
                 //   withAnimation {
                        flipped.toggle()
                  //  }
                }
            }
        }
        .padding(.top, 100)
    }
}

// MARK: - Stack Modifier
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(position) * 8
        let scale = max(1.0 - CGFloat(position) * 0.05, 0.8)
        return self
            .offset(y: offset)
            .scaleEffect(scale)
    }
}

// MARK: - Spaced Repetition Logic
extension FlashCardViewTest {
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
  
    private func prepareSession() {
        allCards = (collection.cards?.allObjects as? [Card]) ?? []
        
        let gradePriority: [CardGrade: Int] = [.new: 0, .again: 1, .hard: 2, .good: 3, .easy: 4]
        
        sessionCards = optionalCards ?? []
        if sessionCards.isEmpty && optionalCards == nil {
            let today = Calendar.current.startOfDay(for: Date())
            let dueCards = allCards.filter { card in
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
                return priority1 < priority2
            }
        } else {
            sessionCards.sort { card1, card2 in
                let priority1 = gradePriority[card1.lastGrade] ?? 5
                let priority2 = gradePriority[card2.lastGrade] ?? 5
                return priority1 < priority2
            }
        }
        
        cardsSeen = 0
        totalCards = sessionCards.count
        currentCardIndex = 0
    }
    
    private func nextCard() {
        guard !sessionCards.isEmpty else { return }
        if currentCardIndex < sessionCards.count - 1 {
            currentCardIndex += 1
        } else {
            currentCardIndex = 0
        }
    }
    
    private func handleHard(_ card: Card) {
        
        hard_cards += 1
        
        card.nextScheduleDate = nextScheduleDateForHard()
        card.lastGrade = .hard
        card.isNew = false
        saveCard(card)
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        if !sessionCards.isEmpty {
            if currentCardIndex >= sessionCards.count {
                currentCardIndex = 0
            }
        }
    }
    
    private func handleGood(_ card: Card) {
        
        good_cards += 1
        
        card.nextScheduleDate = nextScheduleDateForGood()
        card.lastGrade = .good
        card.isNew = false
        saveCard(card)
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        if !sessionCards.isEmpty {
            if currentCardIndex >= sessionCards.count {
                currentCardIndex = 0
            }
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

// MARK: - Preview
struct FlashCardViewTest_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Test Collection"
        
        for i in 1...10 {
            let card = Card(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Calendar.current.startOfDay(for: Date())
            card.isNew = true
            collection.addToCards(card)
        }
        try? context.save()
        
        return FlashCardViewTest(collection: collection, optionalCards: (collection.cards?.allObjects as? [Card]))
            .environment(\.managedObjectContext, context)
    }
}
