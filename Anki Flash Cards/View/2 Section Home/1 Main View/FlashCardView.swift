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
    @State private var open_sheet_custom_cards = false {
        didSet {
            Analytics.logEvent(open_sheet_custom_cards ? "flashcard_custom_cards_sheet_opened" : "flashcard_custom_cards_sheet_closed", parameters: nil)
        }
    }
    
    @ObservedObject private var vm = DesignVM()
    @State private var screenEnterTime = Date()
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                // Header
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
                                if !sessionCards.isEmpty {
                                    Analytics.logEvent("flashcard_open_settings_button_tapped", parameters: nil)
                                    open_sheet_settings_flashcards = true
                                }
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
                                            
                                            // Start Custom Cards "5-10-15..."
                                            VStack {
                                                Button {
                                                    Analytics.logEvent("flashcard_open_custom_cards_button_tapped", parameters: nil)
                                                    open_sheet_custom_cards = true
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
                                                .sheet(isPresented: $open_sheet_custom_cards) {
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
                                                            .onChange(of: selectedCardCount) { newValue,_ in
                                                                Analytics.logEvent("flashcard_picker_selected_number_changed", parameters: ["selectedCardCount": newValue])
                                                            }
                                                            
                                                            Button {
                                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                                generator.impactOccurred()
                                                                
                                                                Analytics.logEvent("flashcard_custom_start_button_tapped", parameters: ["selectedCardCount": selectedCardCount])
                                                                
                                                                let today = Calendar.current.startOfDay(for: Date())
                                                                let dueCards = allCards.filter { card in
                                                                    if card.lastGrade == .again || card.isNew { return true }
                                                                    if let scheduleDate = card.nextScheduleDate {
                                                                        let scheduleDay = Calendar.current.startOfDay(for: scheduleDate)
                                                                        return scheduleDay <= today
                                                                    }
                                                                    return false
                                                                }
                                                                
                                                                sessionCards = Array(dueCards.shuffled().prefix(selectedCardCount))
                                                                
                                                                open_sheet_settings_flashcards = false
                                                                open_sheet_custom_cards = false
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
                                                                .shadow(radius: 5)
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
                                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                                    generator.impactOccurred()
                                                    
                                                    Analytics.logEvent("flashcard_start_all_cards_button_tapped", parameters: ["allCardsCount": allCards.count])
                                                    
                                                    selectedCards = allCards
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        navigateToFlashCards = true
                                                    }
                                                    
                                                    open_sheet_custom_cards = false
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
                                .presentationDetents([.height(300)])
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
                
                // Card stack
                VStack {
                    if !sessionCards.isEmpty {
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
                }
                
                // Finish Screen
                VStack {
                    if sessionCards.isEmpty {
                         // Text "Nice Work..." and Image Win or Lose
                        VStack {
                            HStack {
                                Text("Nice work! Your progress has improved, you've learned even more cards!")
                                .font(.system(size: 20).bold())
                                .foregroundStyle(Color(hex: "#546a50"))
                                .padding(.leading)
                                .onAppear {
                                    Analytics.logEvent("flashcard_finish_screen_appeared", parameters: ["hard_cards": hard_cards, "good_cards": good_cards])
                                }
                                
                                Spacer()
                                
                                Image("cake_for_zelo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 157)
                                    .clipShape(.rect(cornerRadius: 70))
                            } .padding(.vertical)
                        }
                        
                        // Circle "Your Progress" and number of cards know/still learning
                        VStack {
                            HStack {
                                 // Circle
                                VStack {
                                    
                                }
                                
                                // Capsule know/still learning
                                VStack(spacing: 40) {
                                    Text("\(hard_cards)")
                                        .foregroundStyle(.black.opacity(0.6))
                                        .fontWeight(.bold)
                                        .background(
                                            Capsule()
                                                .fill(.orange.opacity(0.4))
                                                .frame(width: 200, height: 50)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.orange, lineWidth: 2)
                                                )
                                        )
                                    
                                    Text("\(good_cards)")
                                        .foregroundStyle(.black.opacity(0.6))
                                        .fontWeight(.bold)
                                        .background(
                                            Capsule()
                                                .fill(.green.opacity(0.4))
                                                .frame(width: 200, height: 50)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.green, lineWidth: 2)
                                                )
                                        )
                                }
                                .padding(.top, 25)
                                .padding(.horizontal, 15)
                                .padding(.leading, 180)
                            }
                            
                                
                                
                            Spacer()
                        }
                        
                        // Buttons: "Back in Menu" and "Practice hard cards"
                        VStack {
                              VStack {
                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    Analytics.logEvent("flashcard_back_to_menu_button_tapped", parameters: nil)
                                    
                                    dismiss()
                                } label: {
                                    Text("Back in Menu")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#546a50"))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                screenEnterTime = Date()
                Analytics.logEvent("flashcard_screen_appeared", parameters: ["collectionId": collection.objectID.uriRepresentation().absoluteString])
                prepareSession()
            }
            .onDisappear {
                logScreenDuration()
            }
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

// MARK: - Preview
struct FlashCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Test Collection"
        
        for i in 1...500 {
            let card = Card(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Calendar.current.startOfDay(for: Date())
            card.isNew = true
            collection.addToCards(card)
        }
        try? context.save()
        
        return FlashCardView(collection: collection, optionalCards: (collection.cards?.allObjects as? [Card]))
            .environment(\.managedObjectContext, context)
    }
}




/*
struct FlashCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var collection: CardCollection
    
    var optionalCards: [Card]?
    
    @State private var currentCardIndex: Int = 0
    @State private var sessionCards: [Card] = []
    @State private var cardsSeen: Int = 0
    @State private var totalCards: Int = 0
    @State private var allCards: [Card] = []
    
    @State private var hard_cards: Int = 0
    @State private var good_cards: Int = 0
    
    @State private var selectedCards: [Card]? = nil
    @State private var navigateToFlashCards = false
    @State private var selectedCardCount = 10
    
    @State private var open_sheet_settings_flashcards = false
    @State private var open_sheet_custom_cards = false
    
    @ObservedObject private var vm = DesignVM()
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
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
                                if !sessionCards.isEmpty {
                                    open_sheet_settings_flashcards = true
                                }
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
                                                        }
                                                    )) {
                                                        Text("Swap Front and Back Sides")
                                                            .font(.headline)
                                                            .foregroundColor(vm.color_text_toggle_front_back_sheet_flash_card_mainset)
                                                    }
                                                    .onTapGesture {
                                                        // Вибрация
                                                        let generator = UIImpactFeedbackGenerator(style: .soft)
                                                        generator.impactOccurred()
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
                                                    open_sheet_custom_cards = true
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
                                                .sheet(isPresented: $open_sheet_custom_cards) {
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
                                                                // Вибрация
                                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                                generator.impactOccurred()
                                                                
                                                                let today = Calendar.current.startOfDay(for: Date())
                                                                let dueCards = allCards.filter { card in
                                                                    if card.lastGrade == .again || card.isNew { return true }
                                                                    if let scheduleDate = card.nextScheduleDate {
                                                                        let scheduleDay = Calendar.current.startOfDay(for: scheduleDate)
                                                                        return scheduleDay <= today
                                                                    }
                                                                    return false
                                                                }
                                                                
                                                                sessionCards = Array(dueCards.shuffled().prefix(selectedCardCount))
                                                               
                                                                // for dismiss sheet
                                                                open_sheet_settings_flashcards = false
                                                                open_sheet_custom_cards = false
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
                                                                .shadow(radius: 5)
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
                                                    // Вибрация
                                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                                    generator.impactOccurred()
                                                 
                                                    selectedCards = allCards
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        navigateToFlashCards = true
                                                    }
                                                    
                                                    // for dismiss sheet
                                                    open_sheet_custom_cards = false
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
                                .presentationDetents([.height(300)])
                            }
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
                                }
                                .padding(.top, 25)
                                .padding(.horizontal, 15)
                            }
                            .padding(.bottom, 30)
                        }
                    }
                }
                
                // Card stack
                VStack {
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
                        
                        
                        Spacer()
                        
                        // Test for flip card
                        VStack {
                            Spacer()
                            Text("Tap for flip card")
                                .foregroundStyle(Color(hex: "#546a50"))
                            
                        }
                    }
                }
                
                // Finish Screen
                VStack {
                    if sessionCards.isEmpty {
                         // Text "Nice Work..." and Image Win or Lose
                        VStack {
                            HStack {
                                Text("Nice work! Your progress has improved, you've learned even more cards!")
                                .font(.system(size: 20).bold())
                                .foregroundStyle(Color(hex: "#546a50"))
                                .padding(.leading)
                                
                                Spacer()
                                
                                Image("cake_for_zelo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 157)
                                    .clipShape(.rect(cornerRadius: 70))
                            } .padding(.vertical)
                        }
                        
                        // Circle "Your Progress" and number of cards know/still learning
                        VStack {
                            HStack {
                                 // Circle
                                VStack {
                                    
                                }
                                
                                // Capsule know/still learning
                                VStack(spacing: 40) {
                                    Text("\(hard_cards)")
                                        .foregroundStyle(.black.opacity(0.6))
                                        .fontWeight(.bold)
                                        .background(
                                            Capsule()
                                                .fill(.orange.opacity(0.4))
                                                .frame(width: 200, height: 50)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.orange, lineWidth: 2)
                                                )
                                        )
                                    
                                    Text("\(good_cards)")
                                        .foregroundStyle(.black.opacity(0.6))
                                        .fontWeight(.bold)
                                        .background(
                                            Capsule()
                                                .fill(.green.opacity(0.4))
                                                .frame(width: 200, height: 50)
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.green, lineWidth: 2)
                                                )
                                        )
                                }
                                .padding(.top, 25)
                                .padding(.horizontal, 15)
                                .padding(.leading, 180)
                            }
                            
                                
                                
                            Spacer()
                        }
                        
                        // Buttons: "Back in Menu" and "Practice hard cards"
                        VStack {
                              VStack {
                                Button {
                                    // Вибрация
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                   
                                    
                                    dismiss()
                                } label: {
                                    Text("Back in Menu")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(hex: "#546a50"))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                prepareSession()
            }
        }
    }
    private func handleSwipe(for card: Card, direction: SwipeDirection) {
        // Вибрация
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
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
    let onSwiped: (FlashCardView.SwipeDirection) -> Void
    
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
                        // Нейтральное положение
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
                if isTop {
                    flipped.toggle()
                }
            }
        }
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
        
        for i in 1...500 {
            let card = Card(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Calendar.current.startOfDay(for: Date())
            card.isNew = true
            collection.addToCards(card)
        }
        try? context.save()
        
        return FlashCardView(collection: collection, optionalCards: (collection.cards?.allObjects as? [Card]))
            .environment(\.managedObjectContext, context)
    }
}

// Saved Last Logic
/*
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
 */*/
