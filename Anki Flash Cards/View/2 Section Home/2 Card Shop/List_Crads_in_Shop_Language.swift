//
//  List_Crads_in_Shop_Language.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-05-08.
//

import SwiftUI
import FirebaseAnalytics

struct List_Crads_in_Shop_Language: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var collection: ShopCollection
    @State private var searchText: String = ""
    
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    private var cards: [ShopCard] {
        let allCards = (collection.cards?.allObjects as? [ShopCard]) ?? []
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
            Color(hex: "#ddead1").ignoresSafeArea()
            
            VStack {
                // Header
                VStack {
                    HStack {
                        Button {
                            Analytics.logEvent("shop_list_tap_back", parameters: [
                                "collection_name": collection.name ?? ""
                            ])
                            logTimeSinceLastAction(event: "tap_back")
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#546a50"))
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        Text("\(collection.name ?? "Language") Cards")
                            .font(.system(size: 18)).bold()
                        Spacer()
                        
                        Button {
                            Analytics.logEvent("shop_list_tap_checkmark", parameters: [
                                "collection_name": collection.name ?? ""
                            ])
                            logTimeSinceLastAction(event: "tap_checkmark")
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#546a50"))
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                
                // Search Cards
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(hex: "#546a50").opacity(0.6)).bold()
                            .padding(.leading)
                        
                        TextField("Search cards", text: $searchText)
                            .foregroundStyle(Color(hex: "#546a50"))
                            .padding([.top, .bottom, .trailing], 10)
                            .onChange(of: searchText) { newValue,_ in
                                Analytics.logEvent("shop_list_search_text_change", parameters: [
                                    "text": newValue
                                ])
                                logTimeSinceLastAction(event: "search_text_change")
                            }
                    }
                    .background(Color(hex: "#546a50").opacity(0.2))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 5)
                }
                
                if cards.isEmpty {
                    Text("No cards available")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(cards) { card in
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            // Front
                                            VStack {
                                                HStack {
                                                    Text(card.frontText ?? "No front text")
                                                        .foregroundStyle(Color(hex: "#546a50"))
                                                        .font(.system(size: 17))
                                                        .padding(.horizontal)
                                                    Spacer()
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
                                                HStack {
                                                    Text(card.backText ?? "No back text")
                                                        .foregroundStyle(Color(hex: "#546a50"))
                                                        .font(.system(size: 17))
                                                        .padding(.horizontal)
                                                    Spacer()
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
                                    .padding(5)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .onAppear {
                screenEnterTime = Date()
                lastActionTime = Date()
                Analytics.logEvent("shop_list_screen_appear", parameters: [
                    "collection_name": collection.name ?? "",
                    "cards_count": cards.count
                ])
            }
            .onDisappear {
                if let enter = screenEnterTime {
                    let duration = Date().timeIntervalSince(enter)
                    Analytics.logEvent("shop_list_screen_disappear", parameters: [
                        "collection_name": collection.name ?? "",
                        "duration_seconds": duration
                    ])
                }
            }
        }
    }
    
    private func logTimeSinceLastAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("shop_list_action_interval", parameters: [
                "event": event,
                "interval_since_last": interval
            ])
        }
        lastActionTime = now
    }
}

/*
struct List_Crads_in_Shop_Language: View {
    @Environment(\.dismiss) private var dismiss
     @ObservedObject var collection: ShopCollection
    @State private var searchText: String = ""
    
    private var cards: [ShopCard] {
        let allCards = (collection.cards?.allObjects as? [ShopCard]) ?? []
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
                        .padding(.horizontal)
                        
                        Spacer()
                        Text("\(collection.name ?? "Language") Cards")
                            .font(.system(size: 18)).bold()
                        Spacer()
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#546a50"))
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
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
                    .padding(.horizontal, 25)
                    .padding(.vertical, 5)
                }
                
                if cards.isEmpty {
                    Text("No cards available")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                   ScrollView {
                        VStack(spacing: 0) {
                            ForEach(cards) { card in
                                VStack {
                                    VStack {
                                        HStack {
                                            // Cell Card
                                            VStack(alignment: .leading) {
                                                
                                                // Front
                                                VStack {
                                                    HStack {
                                                        Text(card.frontText ?? "No front text")
                                                            .foregroundStyle(Color(hex: "#546a50"))
                                                            .font(.system(size: 17))
                                                            .padding(.horizontal)
                                                        
                                                        Spacer()
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
                                                    HStack {
                                                        Text(card.backText ?? "No back text")
                                                            .foregroundStyle(Color(hex: "#546a50"))
                                                            .font(.system(size: 17))
                                                            .padding(.horizontal)
                                                        
                                                        Spacer()
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
                                        .padding(5)
                                    }
                                }
                            }
                        }
                      .padding(.horizontal, 20)
                    }
                }
            }
           .onAppear {
                print("Loaded \(cards.count) cards for \(collection.name ?? "unknown")")
            }
        }
    }
}


struct LookShopCardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create sample ShopCollection
        let collection = ShopCollection(context: context)
        collection.name = "Spanish"
        collection.priority = 100
        collection.creationDate = Date()
        
        // Add sample ShopCards
        for i in 1...5 {
            let card = ShopCard(context: context)
            card.frontText = "Front \(i)"
            card.backText = "Back \(i)"
            card.creationDate = Date()
            card.collection = collection
        }
        
        return NavigationStack {
            List_Crads_in_Shop_Language(collection: collection)
                .environment(\.managedObjectContext, context)
        }
    }
}
*/
