//
//  FlashCardView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-23.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

struct FlashCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    
    var optionalCards: [Card]?
    
    let themeTitle: String
    let level: Int
    let onLevelCompleted: (() -> Void)?

    
    @State private var currentCardIndex: Int = 0
    @State private var sessionCards: [Card] = []
    @State private var cardsSeen: Int = 0 {
        didSet {
            Analytics.logEvent("flashcard_cards_seen_changed", parameters: ["cardsSeen": cardsSeen])
        }
    }
    @State private var totalCards: Int = 0
    @State private var allCards: [Card] = []
    
    @State private var hard_cards: Int = 0 {
        didSet {
            Analytics.logEvent("flashcard_hard_cards_changed", parameters: ["hard_cards": hard_cards])
        }
    }
    @State private var good_cards: Int = 0 {
        didSet {
            Analytics.logEvent("flashcard_good_cards_changed", parameters: ["good_cards": good_cards])
        }
    }
    
    @State private var selectedCards: [Card]? = nil
    @State private var navigateToFlashCards = false
    @State private var selectedCardCount = 10 {
        didSet {
            Analytics.logEvent("flashcard_selected_card_count_changed", parameters: ["selectedCardCount": selectedCardCount])
        }
    }
    
    @State private var open_sheet_settings_flashcards = false {
        didSet {
            Analytics.logEvent(open_sheet_settings_flashcards ? "flashcard_settings_sheet_opened" : "flashcard_settings_sheet_closed", parameters: nil)
        }
    }
    
    @ObservedObject private var vm = DesignVM()
    @State private var screenEnterTime = Date()
    @State private var completedCards: [Card] = []
    @EnvironmentObject var appNavVM: AppNavigationVM
    @State private var userVocabulary: String = ""
    @State private var homeVM: HomeVM?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                if !sessionCards.isEmpty {
                    // Full header for flashcards
                    VStack {
                        // buttons + progress
                        VStack(spacing: 10) {
                            
                            HStack {
                                Button {
                                    Analytics.logEvent("flashcard_dismiss_button_tapped", parameters: nil)
                                    logScreenDurationAndDismiss()
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
                                    .onAppear {
                                        Analytics.logEvent("flashcard_progress_text_appeared", parameters: ["cardsSeen": cardsSeen, "cardsLeft": sessionCards.count])
                                    }
                                
                                Spacer()
                                
                                Button {
                                        Analytics.logEvent("flashcard_open_settings_button_tapped", parameters: nil)
                                        open_sheet_settings_flashcards = true
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .padding(.horizontal)
                                .sheet(isPresented: $open_sheet_settings_flashcards) {
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
                                                                Analytics.logEvent("flashcard_toggle_swap_sides_changed", parameters: ["swapSides": newValue])
                                                            }
                                                        )) {
                                                            Text("Swap Front and Back Sides")
                                                                .font(.headline)
                                                                .foregroundColor(vm.color_text_toggle_front_back_sheet_flash_card_mainset)
                                                        }
                                                        .onTapGesture {
                                                            let generator = UIImpactFeedbackGenerator(style: .soft)
                                                            generator.impactOccurred()
                                                            Analytics.logEvent("flashcard_toggle_swap_sides_tapped", parameters: nil)
                                                        }
                                                        .tint(vm.color_tint_toggle_front_back_sheet_flash_card_mainset)
                                                        .padding()
                                                        .background(vm.color_back_toggle_front_back_sheet_flash_card_mainset)
                                                        .cornerRadius(12)
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                
                                                // Start Button
                                                VStack {
                                                    Spacer()
                                                    
                                                    Button {
                                                       let generator = UIImpactFeedbackGenerator(style: .medium)
                                                        generator.impactOccurred()
                                                        
                                                        open_sheet_settings_flashcards = false
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
                                                        .shadow(radius: 5)
                                                    }
                                                    .padding(.horizontal)
                                                }
                                            }
                                            .padding(.top)
                                            
                                            Spacer()
                                        }
                                    }
                                    .presentationDetents([.height(200)])
                                }
                            }
                            .padding(.bottom, 10)
                            .padding(.top, 5)
                            
                            ZStack {
                                ProgressView(value: Float(cardsSeen), total: Float(cardsSeen + sessionCards.count))
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(height: 5)
                                    .onAppear {
                                        Analytics.logEvent("flashcard_progress_view_appeared", parameters: ["cardsSeen": cardsSeen, "cardsLeft": sessionCards.count])
                                    }
                            }
                            .padding(.horizontal)
                        }
                        
                        // 18 hard | 36 good
                        VStack {
                            if !sessionCards.isEmpty {
                                VStack {
                                    HStack {
                                        Text("\(hard_cards)")
                                            .background(
                                                Rectangle()
                                                    .fill(.orange.opacity(0.4))
                                                    .frame(width: 45, height: 30)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.orange, lineWidth: 2)
                                                    )
                                            )
                                            .onAppear {
                                                Analytics.logEvent("flashcard_hard_cards_label_appeared", parameters: ["hard_cards": hard_cards])
                                            }
                                        
                                        Spacer()
                                        
                                        Text("\(good_cards)")
                                            .background(
                                                Rectangle()
                                                    .fill(.green.opacity(0.4))
                                                    .frame(width: 45, height: 30)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.green, lineWidth: 2)
                                                    )
                                                
                                            )
                                            .onAppear {
                                                Analytics.logEvent("flashcard_good_cards_label_appeared", parameters: ["good_cards": good_cards])
                                            }
                                    }
                                    .padding(.top, 25)
                                    .padding(.horizontal, 15)
                                }
                                .padding(.bottom, 30)
                            }
                        }
                    }
                } else {
                    // Simplified header for chat: only exit button
                    HStack {
                        Button {
                            Analytics.logEvent("flashcard_dismiss_button_tapped", parameters: nil)
                            logScreenDurationAndDismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#546a50"))
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                
                // Card stack or Chat
                if !sessionCards.isEmpty {
                    VStack {
                        ZStack {
                            ForEach(Array(sessionCards.enumerated().prefix(3)), id: \.element) { (index, card) in
                                let isTop = index == currentCardIndex
                                
                                CardView(
                                    card: card,
                                    collection: collection,
                                    isTop: isTop,
                                    onSwiped: { direction in
                                        Analytics.logEvent("flashcard_card_swiped", parameters: ["direction": direction == .left ? "left" : "right", "cardId": card.objectID.uriRepresentation().absoluteString])
                                        handleSwipe(for: card, direction: direction)
                                    },
                                    onTapFlip: {
                                        Analytics.logEvent("flashcard_card_tapped_to_flip", parameters: ["cardId": card.objectID.uriRepresentation().absoluteString])
                                    }
                                )
                                .stacked(at: index - currentCardIndex, in: min(3, sessionCards.count - currentCardIndex))
                                .zIndex(Double(sessionCards.count - index))
                                .allowsHitTesting(isTop)
                            }
                        }
                        .frame(height: 400)
                        .padding(.horizontal)
                        
                        
                        Spacer()
                        
                        // Test for flip card
                        VStack {
                            Spacer()
                            
                            Text("Tap for flip card")
                                .foregroundStyle(Color(hex: "#546a50"))
                                .padding(.top, 50)
                                .onTapGesture {
                                    Analytics.logEvent("flashcard_tap_for_flip_card_text_tapped", parameters: nil)
                                }
                        }
                    }
                } else {
                    let themeIndex = homeVM?.themes.firstIndex(where: { $0.title == themeTitle }) ?? 0
                    let questions = homeVM?.getQuestionsForLevel(themeIndex: themeIndex, level: level) ?? []
                     ChatView(theme: themeTitle, vocabulary: userVocabulary, questions: questions)
                        .environmentObject(vm)
                }
            }
            .onAppear {
                screenEnterTime = Date()
                Analytics.logEvent("flashcard_screen_appeared", parameters: ["collectionId": collection.objectID.uriRepresentation().absoluteString])
                prepareSession()
                fetchUserVocabulary()
                if homeVM == nil {
                    homeVM = HomeVM(context: viewContext)
                }
            }
            .onDisappear {
                logScreenDuration()
                finishSession()
            }
        }
    }
    
    private func fetchUserVocabulary() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try viewContext.fetch(request)
            userVocabulary = users.first?.vocabulary_all_words ?? ""
        } catch {
            print("Error fetching user: \(error)")
        }
    }
    
    private func handleSwipe(for card: Card, direction: SwipeDirection) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        switch direction {
        case .left:
            handleHard(card)
        case .right:
            handleGood(card)
        }
    }
    
    private func logScreenDuration() {
        let duration = Date().timeIntervalSince(screenEnterTime)
        Analytics.logEvent("flashcard_screen_duration", parameters: ["duration_sec": duration])
    }
    
    private func logScreenDurationAndDismiss() {
        logScreenDuration()
        dismiss()
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
    let onSwiped: (FlashCardView.SwipeDirection) -> Void
    let onTapFlip: () -> Void
    
    @State private var flipped = false
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    private var cardBackgroundColor: Color {
        if offset.width > 0 {
            return Color.green
        } else if offset.width < 0 {
            return Color.orange
        } else {
            return Color.white
        }
    }
  
    var body: some View {
        let swapSides = collection.swapSides
        let frontText = swapSides ? (card.backText ?? "") : (card.frontText ?? "")
        let backText = swapSides ? (card.frontText ?? "") : (card.backText ?? "")
        let displayText = flipped ? backText : frontText
        GeometryReader { geometry in
            VStack {
                ZStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(cardBackgroundColor, lineWidth: 2)
                            )
                            .padding()
                            .padding(.bottom)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height * 1.5)
                    }
                    
                    if offset.width > 0 {
                        Text("Know")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundColor(cardBackgroundColor)
                            .padding()
                    } else if offset.width < 0 {
                        Text("Still learning")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundColor(cardBackgroundColor)
                            .padding()
                    } else {
                        Text(displayText)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding()
                    }
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
                            let direction: FlashCardView.SwipeDirection = horizontal > 0 ? .right : .left
                            
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
                withAnimation {
                    flipped.toggle()
                    onTapFlip()
                }
            }
            .animation(.easeInOut, value: flipped)
        }
    }
}

// MARK: - Spaced Repetition Logic (FULL ANALYTICS VERSION)
extension FlashCardView {
    // Время старта сессии
    private var sessionStartTimeKey: String { "flashcard_session_start_time" }
    private var lastCardTimeKey: String { "flashcard_last_card_time" }
    
    private func nextScheduleDateForHard() -> Date {
        let date = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        Analytics.logEvent("flashcard_next_schedule_date_for_hard", parameters: ["nextDate": date.timeIntervalSince1970])
        return date
    }

    private func nextScheduleDateForGood() -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let startOfTomorrow = Calendar.current.startOfDay(for: tomorrow)
        let date = Calendar.current.date(byAdding: .minute, value: 1, to: startOfTomorrow)!
        Analytics.logEvent("flashcard_next_schedule_date_for_good", parameters: ["nextDate": date.timeIntervalSince1970])
        return date
    }
    
    private func prepareSession() {
        Analytics.logEvent("flashcard_prepare_session_started", parameters: nil)

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
            sessionCards = dueCards.sorted { (gradePriority[$0.lastGrade] ?? 5) < (gradePriority[$1.lastGrade] ?? 5) }
        } else {
            sessionCards.sort { (gradePriority[$0.lastGrade] ?? 5) < (gradePriority[$1.lastGrade] ?? 5) }
        }

        cardsSeen = 0
        totalCards = sessionCards.count
        currentCardIndex = 0
        completedCards = []

        // Логируем старт сессии
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: sessionStartTimeKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastCardTimeKey)
        
        Analytics.logEvent("flashcard_prepare_session_finished", parameters: [
            "totalCards": totalCards,
            "sessionCardsCount": sessionCards.count,
            "allCardsCount": allCards.count
        ])
    }
    
    private func nextCard() {
        let now = Date().timeIntervalSince1970
        let lastTime = UserDefaults.standard.double(forKey: lastCardTimeKey)
        let timeBetween = now - lastTime
        UserDefaults.standard.set(now, forKey: lastCardTimeKey)
        
        Analytics.logEvent("flashcard_next_card", parameters: [
            "currentIndex_before": currentCardIndex,
            "sessionCardsRemaining": sessionCards.count,
            "timeSinceLastCard": timeBetween
        ])
        
        guard !sessionCards.isEmpty else {
            Analytics.logEvent("flashcard_next_card_no_cards_left", parameters: nil)
            return
        }

        if currentCardIndex < sessionCards.count - 1 {
            currentCardIndex += 1
        } else {
            currentCardIndex = 0
        }
        
        Analytics.logEvent("flashcard_next_card_after", parameters: [
            "currentIndex_after": currentCardIndex
        ])
    }

    private func handleHard(_ card: Card) {
        hard_cards += 1

        let now = Date().timeIntervalSince1970
        let lastTime = UserDefaults.standard.double(forKey: lastCardTimeKey)
        let responseTime = now - lastTime
        UserDefaults.standard.set(now, forKey: lastCardTimeKey)
        
        Analytics.logEvent("flashcard_handle_hard", parameters: [
            "cardId": card.objectID.uriRepresentation().absoluteString,
            "responseTime": responseTime,
            "currentIndex": currentCardIndex
        ])
        
        completedCards.append(card)
        
        card.nextScheduleDate = nextScheduleDateForHard()
        card.lastGrade = .hard
        card.isNew = false
        saveCard(card)
        
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        
        if !sessionCards.isEmpty && currentCardIndex >= sessionCards.count {
            currentCardIndex = 0
            Analytics.logEvent("flashcard_handle_hard_reset_index", parameters: ["currentIndex": currentCardIndex])
        }
    }
    
    private func handleGood(_ card: Card) {
        good_cards += 1

        let now = Date().timeIntervalSince1970
        let lastTime = UserDefaults.standard.double(forKey: lastCardTimeKey)
        let responseTime = now - lastTime
        UserDefaults.standard.set(now, forKey: lastCardTimeKey)
        
        Analytics.logEvent("flashcard_handle_good", parameters: [
            "cardId": card.objectID.uriRepresentation().absoluteString,
            "responseTime": responseTime,
            "currentIndex": currentCardIndex
        ])
        
        completedCards.append(card)
        
        card.nextScheduleDate = nextScheduleDateForGood()
        card.lastGrade = .good
        card.isNew = false
        saveCard(card)
        
        sessionCards.remove(at: currentCardIndex)
        cardsSeen += 1
        totalCards = cardsSeen + sessionCards.count
        
        if !sessionCards.isEmpty && currentCardIndex >= sessionCards.count {
            currentCardIndex = 0
            Analytics.logEvent("flashcard_handle_good_reset_index", parameters: ["currentIndex": currentCardIndex])
        }
    }
    
    private func saveCard(_ card: Card) {
        Analytics.logEvent("flashcard_save_card", parameters: [
            "cardId": card.objectID.uriRepresentation().absoluteString,
            "frontText": card.frontText ?? "",
            "backText": card.backText ?? "",
            "lastGrade": card.lastGrade.rawValue,
            "nextScheduleDate": card.nextScheduleDate?.timeIntervalSince1970 ?? 0
        ])
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving card: \(error)")
            Analytics.logEvent("flashcard_save_card_failed", parameters: ["error": error.localizedDescription])
        }
    }
    
    /// Вызывать при выходе из сессии (например, при закрытии экрана)
    private func finishSession() {
        let start = UserDefaults.standard.double(forKey: sessionStartTimeKey)
        let duration = Date().timeIntervalSince1970 - start
        Analytics.logEvent("flashcard_session_finished", parameters: [
            "sessionDuration": duration,
            "totalCardsSeen": cardsSeen,
            "hard_cards": hard_cards,
            "good_cards": good_cards
        ])
        onLevelCompleted?()
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
