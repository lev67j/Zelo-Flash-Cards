//
//  EditSetView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-22.
//

import CoreData
import SwiftUI
import FirebaseAnalytics

struct EditSetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var collection: CardCollection

    @State private var collectionName: String
    @State private var selectedPriority: Int64
    @State private var add_name_alert = false
    
    @State private var screenEnterTime = Date()
    
    init(collection: CardCollection) {
        self.collection = collection
        self._collectionName = State(initialValue: collection.name ?? "")
        self._selectedPriority = State(initialValue: Int64(collection.priority))
    }
    
    // For list cards
    @State private var searchText: String = "" {
        didSet {
            Analytics.logEvent("editset_search_text_changed", parameters: ["searchText": searchText])
        }
    }
    @State private var showEditCardView: Bool = false
    @State private var cardToEdit: Card?
    @State private var showDeleteAlert: Bool = false
    @State private var cardToDelete: Card?
    
    @State private var card_front: String = ""
    @State private var card_back: String = ""
   
    @FocusState private var front_text_focused: Bool
    
    private var cards: [Card] {
        let allCards = (collection.cards?.allObjects as? [Card]) ?? []
        let sortedCards = allCards.sorted { $0.creationDate ?? Date.distantPast > $1.creationDate ?? Date.distantPast }
        if searchText.isEmpty {
            return sortedCards
        } else {
            return sortedCards.filter { card in
                (card.frontText?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (card.backText?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    @State private var cardToFocus: Card? = nil

    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                   // All
                    VStack {
                        // Header: back button + save button
                        VStack {
                            HStack {
                                Button {
                                    Analytics.logEvent("editset_back_button_tapped", parameters: nil)
                                    logScreenDurationAndDismiss()
                                } label: {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                Button {
                                    Analytics.logEvent("editset_save_button_tapped", parameters: nil)
                                    if collectionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        add_name_alert = true
                                    } else {
                                        saveCollection()
                                        logScreenDurationAndDismiss()
                                    }
                                 } label: {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .padding(.horizontal)
                                .alert(isPresented: $add_name_alert) {
                                    Alert(
                                        title: Text("Please add name"),
                                        message: Text(""),
                                        dismissButton: .cancel()
                                    )
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Spacer()
                        
                        ScrollView {
                            // Title + Priority
                            VStack(spacing: 15) {
                                // Name Field
                                VStack {
                                    TextField("Collection Name", text: $collectionName, onEditingChanged: { began in
                                        if began {
                                            Analytics.logEvent("editset_collectionname_edit_started", parameters: nil)
                                        }
                                    }, onCommit: {
                                        Analytics.logEvent("editset_collectionname_edit_commited", parameters: ["collectionName": collectionName])
                                    })
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
                                                        Analytics.logEvent("editset_priority_selected", parameters: ["priority": 20])
                                                    }
                                                    
                                                    PriorityButton(title: "Middle", color: Color(hex: "9ea99c"), isSelected: selectedPriority == 50) {
                                                        selectedPriority = 50
                                                        Analytics.logEvent("editset_priority_selected", parameters: ["priority": 50])
                                                    }
                                                    
                                                    PriorityButton(title: "High", color: Color(hex: "90997f"), isSelected: selectedPriority == 100) {
                                                        selectedPriority = 100
                                                        Analytics.logEvent("editset_priority_selected", parameters: ["priority": 100])
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        Spacer()
                                    }
                                }
                                
                                // Search Cards
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(Color(hex: "#546a50").opacity(0.6))
                                            .bold()
                                            .padding(.leading)
                                        
                                        TextField("Search cards", text: $searchText)
                                            .foregroundStyle(Color(hex: "#546a50"))
                                            .padding([.top, .bottom, .trailing], 10)
                                    }
                                    .background(Color(hex: "#546a50").opacity(0.2))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                                }
                            }
                            
                            // List Cards
                            VStack(spacing: 30) {
                                VStack(spacing: 0) {
                                    ForEach(cards) { card in
                                        CardCell(card: card, shouldFocusFront: card == cardToFocus)
                                            .environment(\.managedObjectContext, viewContext)
                                            .onChange(of: cardToFocus) { newValue, _ in
                                                if newValue != cardToFocus {
                                                    cardToFocus = nil // сбрасываем после фокусировки
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                     // Add Card
                    add_card_button
                }
            }
        }
        .onAppear {
            screenEnterTime = Date()
            Analytics.logEvent("editset_screen_appeared", parameters: nil)
        }
        .onDisappear {
            logScreenDuration()
        }
    }
    
    private func addCard() {
        withAnimation {
            let newCard = Card(context: viewContext)
            newCard.frontText = "New Card"
            newCard.backText = "New Card"
            newCard.collection = collection
            newCard.isNew = true
            newCard.creationDate = Date()
            Analytics.logEvent("editset_card_added", parameters: nil)
            
            cardToFocus = newCard  // Устанавливаем фокус на новую карточку
        }
    }
  
    var add_card_button: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    Analytics.logEvent("editset_add_card_button_tapped", parameters: nil)
                    withAnimation {
                        addCard()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color(hex: "90997f"))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
                
            }
        }
    }
    
    private func saveCollection() {
        collection.name = collectionName
        collection.priority = selectedPriority

        do {
            try viewContext.save()
            Analytics.logEvent("editset_collection_saved", parameters: [
                "collectionName": collectionName,
                "priority": selectedPriority
            ])
            dismiss()
        } catch {
            let nsError = error as NSError
            Analytics.logEvent("editset_save_collection_error", parameters: [
                "error": nsError.localizedDescription
            ])
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func logScreenDuration() {
        let duration = Date().timeIntervalSince(screenEnterTime)
        Analytics.logEvent("editset_screen_duration", parameters: ["duration_sec": duration])
    }
    
    private func logScreenDurationAndDismiss() {
        logScreenDuration()
        dismiss()
    }
}

struct CardCell: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var card: Card
    @State private var frontText: String
    @State private var backText: String
    @FocusState private var frontTextFocused: Bool
    
    let shouldFocusFront: Bool  // новый параметр
    
    init(card: Card, shouldFocusFront: Bool = false) {
        self.card = card
        self._frontText = State(initialValue: card.frontText ?? "")
        self._backText = State(initialValue: card.backText ?? "")
        self.shouldFocusFront = shouldFocusFront
    }

    var body: some View {
        VStack {
            // Cell
            VStack {
                HStack {
                    // Card Cell
                    VStack(alignment: .leading) {
                        VStack {
                            TextField("no text", text: $frontText)
                                .focused($frontTextFocused)
                                .foregroundStyle(Color(hex: "#546a50"))
                                .font(.system(size: 17))
                                .padding(.horizontal)
                                .onChange(of: frontText) { newValue,_ in
                                    Analytics.logEvent("editset_card_fronttext_changed", parameters: ["text": newValue])
                                }
                                .onAppear {
                                    if shouldFocusFront {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            frontTextFocused = true
                                        }
                                    }
                                }
                       
                            Rectangle()
                                .foregroundStyle(Color(hex: "#546a50"))
                                .frame(height: 1.3)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Term")
                                    .foregroundStyle(Color(hex: "#546a50"))
                                    .font(.system(size: 11))
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Back
                        VStack {
                            TextField("no text", text: $backText)
                                .foregroundStyle(Color(hex: "#546a50"))
                                .font(.system(size: 17))
                                .padding(.horizontal)
                                .onChange(of: backText) { newValue,_ in
                                    Analytics.logEvent("editset_card_backtext_changed", parameters: ["text": newValue])
                                }
                            
                            Rectangle()
                                .foregroundStyle(Color(hex: "#546a50"))
                                .frame(height: 1.3)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Definition")
                                    .foregroundStyle(Color(hex: "#546a50"))
                                    .font(.system(size: 11))
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height: 150)
                .background(Color(hex: "#546a50").opacity(0.2))
                .padding(.vertical, 5)
            }
            .onDisappear {
                saveCard()
            }
        }
    }
    
    private func saveCard() {
        card.frontText = frontText
        card.backText = backText

        do {
            try viewContext.save()
            Analytics.logEvent("editset_card_saved", parameters: [
                "frontText": frontText,
                "backText": backText
            ])
        } catch {
            let nsError = error as NSError
            Analytics.logEvent("editset_save_card_error", parameters: [
                "error": nsError.localizedDescription
            ])
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
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(isSelected ? color : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .black)
               .cornerRadius(20)
        }
    }
}



            /*
struct EditSetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var collection: CardCollection

    @State private var collectionName: String
    @State private var selectedPriority: Int64
    @State private var add_name_alert = false
    
    init(collection: CardCollection) {
        self.collection = collection
        self._collectionName = State(initialValue: collection.name ?? "")
        self._selectedPriority = State(initialValue: Int64(collection.priority))
    }
    
    // For list cards
    @State private var searchText: String = ""
    @State private var showEditCardView: Bool = false
    @State private var cardToEdit: Card?
    @State private var showDeleteAlert: Bool = false
    @State private var cardToDelete: Card?
    
    @State private var card_front: String = ""
    @State private var card_back: String = ""
   
    @FocusState private var front_text_focused: Bool
    
    private var cards: [Card] {
        let allCards = (collection.cards?.allObjects as? [Card]) ?? []
        let sortedCards = allCards.sorted { $0.creationDate ?? Date.distantPast > $1.creationDate ?? Date.distantPast }
        if searchText.isEmpty {
            return sortedCards
        } else {
            return sortedCards.filter { card in
                (card.frontText?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (card.backText?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }

    var body: some View {
        ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
            
            VStack {
                ZStack {
                   // All
                    VStack {
                        // Header: back button + save button
                        VStack {
                            HStack {
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                Button {
                                    if collectionName != "" && collectionName != " " && collectionName != "  " {
                                        saveCollection()
                                        dismiss()
                                    } else {
                                        add_name_alert = true
                                    }
                                 } label: {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20)).bold()
                                        .foregroundStyle(Color(hex: "#546a50"))
                                }
                                .padding(.horizontal)
                                .alert(isPresented: $add_name_alert) {
                                    Alert(
                                        title: Text("Please add name"),
                                        message: Text(""),
                                        dismissButton: .cancel()
                                    )
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Spacer()
                        
                        ScrollView {
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
                                                    }
                                                    
                                                    PriorityButton(title: "Middle", color: Color(hex: "9ea99c"), isSelected: selectedPriority == 50) {
                                                        selectedPriority = 50
                                                    }
                                                    
                                                    PriorityButton(title: "High", color: Color(hex: "90997f"), isSelected: selectedPriority == 100) {
                                                        selectedPriority = 100
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        
                                        Spacer()
                                    }
                                }
                                
                                // Search Cards
                                VStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(Color(hex: "#546a50").opacity(0.6))
                                            .bold()
                                            .padding(.leading)
                                        
                                        TextField("Search cards", text: $searchText)
                                            .foregroundStyle(Color(hex: "#546a50"))
                                            .padding([.top, .bottom, .trailing], 10)
                                    }
                                    .background(Color(hex: "#546a50").opacity(0.2))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 5)
                                }
                            }
                            
                            // List Cards
                            VStack(spacing: 30) {
                                VStack(spacing: 0) {
                                    ForEach(cards) { card in
                                        CardCell(card: card)
                                            .environment(\.managedObjectContext, viewContext)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                     // Add Card
                    add_card_button
                }
            }
        }
    }
    
    var add_card_button: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        addCard()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color(hex: "90997f"))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                }
                .padding(.bottom, 30)
                .padding(.trailing, 20)
                
            }
        }
    }
    
    private func saveCollection() {
        collection.name = collectionName
        collection.priority = selectedPriority

        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func addCard() {
        withAnimation {
            let newCard = Card(context: viewContext)
            newCard.frontText = "New Card"
            newCard.backText = "New Card"
            newCard.collection = collection
            newCard.isNew = true
            newCard.creationDate = Date()
        }
    }
}

struct CardCell: View {
    init(card: Card) {
        self.card = card
        self._frontText = State(initialValue: card.frontText ?? "")
        self._backText = State(initialValue: card.backText ?? "")
    }
    
    struct CardData: Decodable {
        let front: String
        let back: String
    }
    
    @Environment(\.managedObjectContext) private var viewContext
   
    @ObservedObject var card: Card
    @State private var frontText: String
    @State private var backText: String
      
    @State private var showJSONInput = false
    @State private var jsonText: String = ""
   
    var body: some View {
        // Cell
        VStack {
            VStack {
                HStack {
                    // Cell Card
                    VStack(alignment: .leading) {
                        
                        // Front
                        VStack {
                            TextField("no text", text: $frontText)
                                .foregroundStyle(Color(hex: "#546a50"))
                                .font(.system(size: 17))
                                .padding(.horizontal)
                            
                            Rectangle()
                                .foregroundStyle(Color(hex: "#546a50"))
                                .frame(height: 1.3)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Term")
                                    .foregroundStyle(Color(hex: "#546a50"))
                                    .font(.system(size: 11))
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Back
                        VStack {
                            TextField("no text", text: $backText)
                                .foregroundStyle(Color(hex: "#546a50"))
                                .font(.system(size: 17))
                                .padding(.horizontal)
                            
                            Rectangle()
                                .foregroundStyle(Color(hex: "#546a50"))
                                .frame(height: 1.3)
                                .padding(.horizontal)
                            
                            HStack {
                                Text("Definition")
                                    .foregroundStyle(Color(hex: "#546a50"))
                                    .font(.system(size: 11))
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height: 150)
                .background(Color(hex: "#546a50").opacity(0.2))
                .padding(.vertical, 5)
            }
            .onDisappear {
                saveCard()
            }
        }
        
        // ADD DELETE FUNC !!! (in trailing scroll)
    }
    
    
    private func saveCard() {
        card.frontText = frontText
        card.backText = backText

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EditSetView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let collection = CardCollection(context: context)
        collection.name = "Sample Collection"
        collection.creationDate = Date()
        collection.priority = 50
        
        // Add sample cards
        let card1 = Card(context: context)
        card1.frontText = "Question 1"
        card1.backText = "Answer 1"
        card1.creationDate = Date()
        let card2 = Card(context: context)
        card2.frontText = "Question 2"
        card2.backText = "Answer 2"
        card2.creationDate = Date()
        let card3 = Card(context: context)
        card3.frontText = "Question 3"
        card3.backText = "Answer 3"
        card3.creationDate = Date()
        let card4 = Card(context: context)
        card4.frontText = "Question 4"
        card4.backText = "Answer 4"
        let card5 = Card(context: context)
        card5.frontText = "Question 5"
        card5.backText = "Answer 5"
        let card6 = Card(context: context)
        card6.frontText = "Question 6"
        card6.backText = "Answer 6"
        let card7 = Card(context: context)
        card7.frontText = "Question 7"
        card7.backText = "Answer 7"
        card7.creationDate = Date()
        let card8 = Card(context: context)
        card8.frontText = "Question 8"
        card8.backText = "Answer 8"
        card8.creationDate = Date()
        .addingTimeInterval(-3600)
        
        collection.addToCards(card1)
        collection.addToCards(card2)
        collection.addToCards(card3)
        collection.addToCards(card4)
        collection.addToCards(card5)
        collection.addToCards(card6)
        collection.addToCards(card7)
        collection.addToCards(card8)
        
        return EditSetView(collection: collection)
            .environment(\.managedObjectContext, context)
    }
}
 */
