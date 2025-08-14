//
//  HomeView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var vm: HomeVM
    @ObservedObject private var design = DesignVM()

    init(context: NSManagedObjectContext) {
        self.vm = HomeVM(context: context)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                design.color_back_home_view.ignoresSafeArea()
                VStack {
                    // Горизонтальный скролл с языками
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(vm.availableLanguages) { language in
                                Button(action: {
                                    vm.switchLanguage(to: language.name)
                                    Analytics.logEvent("home_language_button_tapped", parameters: ["language": language.name])
                                }) {
                                    HStack(spacing: 8) {
                                        Text(language.flag)
                                            .font(.system(size: 24))
                                        Text(language.name)
                                            .font(.headline)
                                            .foregroundColor(vm.selectedLanguage == language.name ? .white : .gray)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(vm.selectedLanguage == language.name ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // Основной контент
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            ForEach(vm.themes.indices, id: \.self) { themeIndex in
                                let theme = vm.themes[themeIndex]
                                VStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(theme.title)
                                                .font(.title3)
                                                .foregroundColor(design.color_name_language_cell_set_home)
                                            Spacer()
                                        }
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(design.color_line_cell_set_home)
                                        HStack {
                                            Text("\(theme.cards.count) words")
                                                .foregroundColor(design.color_number_cards_cell_set_home)
                                                .font(.system(size: 17))
                                            Spacer()
                                        }
                                        HStack {
                                            Image(theme.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 150)
                                    .background(design.color_back_cell_set_home)
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(design.color_overlay_cell_set_home, lineWidth: 8))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)

                                    VStack(spacing: 16) {
                                        ForEach(1...11, id: \.self) { level in
                                            Button(action: {
                                                vm.selectedThemeIndex = themeIndex
                                                vm.selectedLevel = level
                                                let cards = vm.getCardsForLevel(themeIndex: themeIndex, level: level)
                                                Analytics.logEvent("home_level_selected", parameters: [
                                                    "theme": theme.title,
                                                    "level": level,
                                                    "card_count": cards.count
                                                ])
                                                if !cards.isEmpty {
                                                    vm.navigateToFlashCard = true
                                                } else {
                                                    print("No cards for theme \(theme.title), level \(level)")
                                                }
                                            }) {
                                                Text("\(level)")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .frame(width: 50, height: 50)
                                                    .background(Circle().fill(Color.blue))
                                                    .shadow(radius: 4)
                                            }
                                        }
                                    }

                                    HStack(spacing: 8) {
                                        Rectangle()
                                            .fill(design.color_line_cell_set_home)
                                            .frame(height: 1)
                                        Image(systemName: "lock.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(.gray)
                                        Rectangle()
                                            .fill(design.color_line_cell_set_home)
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                        .padding(.bottom, 70)
                        .onAppear {
                            Analytics.logEvent("ai_quest_scrollview_appear", parameters: nil)
                        }
                    }
                }
                // Add collection button
/*
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            vm.showingAddCollection = true
                            Analytics.logEvent("home_tap_add_collection_button", parameters: nil)
                            vm.logTimeSinceLastAction(event: "tap_add_collection_button")
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(design.color_back_button_add_collection_home)
                                .foregroundColor(design.color_text_button_add_collection_home)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.2), radius: 5)
                        }
                        .padding(.bottom, 85)
                        .padding(.trailing, 20)
                    }
                }
 */
            }
            .sheet(isPresented: $vm.showingAddCollection) {
                AddCollectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
                    .onAppear {
                        Analytics.logEvent("home_open_add_collection_sheet", parameters: nil)
                        vm.logTimeSinceLastAction(event: "open_add_collection_sheet")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                vm.screenEnterTime = Date()
                vm.lastActionTime = Date()
                Analytics.logEvent("home_screen_appear", parameters: ["language": vm.selectedLanguage])
                if !vm.isFirstOpen {
                    vm.isFirstOpen = true
                    Analytics.logEvent("home_first_open", parameters: ["language": vm.selectedLanguage])
                }
            }
            .onDisappear {
                if let start = vm.screenEnterTime {
                    let duration = Date().timeIntervalSince(start)
                    Analytics.logEvent("home_screen_disappear", parameters: [
                        "duration_seconds": duration,
                        "language": vm.selectedLanguage
                    ])
                }
            }
            .navigationDestination(isPresented: $vm.navigateToFlashCard) {
                if let themeIndex = vm.selectedThemeIndex, let level = vm.selectedLevel {
                    let cardDataArray = vm.getCardsForLevel(themeIndex: themeIndex, level: level)
                    let cards = cardDataArray.map { cardData in
                        let card = Card(context: viewContext)
                        card.frontText = cardData.front
                        card.backText = cardData.back
                        return card
                    }
                    FlashCardView(collection: CardCollection(context: viewContext), optionalCards: cards)
                        .navigationBarBackButtonHidden(true)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(context: PersistenceController.preview.container.viewContext)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

/*
struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
  
    @State private var navigateToMainCard = false
    @State private var navigateToCardShop = false
    @State private var showingAddCollection = false
    @ObservedObject private var vm = DesignVM()
    
    private var sortedCollections: [CardCollection] {
        collections.sorted { lhs, rhs in
            lhs.priority > rhs.priority
        }
    }
    
    private let isFirstOpenKey = "isFirstOpen"
    @AppStorage("isFirstOpenKey") private var isFirstOpen = false
    
    // MARK: - Analytics helpers
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        NavigationStack {
            ZStack {
                vm.color_back_home_view
                    .ignoresSafeArea()
                
                VStack {
                    search_language_button_and_settings
                    
                    if sortedCollections.isEmpty {
                        empty_desk_user
                    } else {
                        VStack {
                            ScrollView {
                                HStack {
                                    Text("Sets")
                                        .foregroundColor(vm.color_title_sets)
                                        .font(.system(size: 17)).bold()
                                        .padding(.horizontal, 13)
                                    Spacer()
                                }
                                
                                ForEach(sortedCollections) { collection in
                                    NavigationLink {
                                        MainSetCardView(collection: collection)
                                            .navigationBarBackButtonHidden(true)
                                            .onAppear {
                                                Analytics.logEvent("home_open_collection", parameters: [
                                                    "collectionName": collection.name ?? "",
                                                    "priority": collection.priority
                                                ])
                                                logTimeSinceLastAction(event: "open_collection")
                                            }
                                    } label: {
                                        CollectionCardView(collection: collection)
                                    } 
                                }
                            }
                        }
                    }
                }
                add_collection_button
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
                    .onAppear {
                        Analytics.logEvent("home_open_add_collection_sheet", parameters: nil)
                        logTimeSinceLastAction(event: "open_add_collection_sheet")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                screenEnterTime = Date()
                lastActionTime = Date()
                Analytics.logEvent("home_screen_appear", parameters: [
                    "collections_count": collections.count
                ])
                
                if isFirstOpen == false {
                    isFirstOpen = true
                    navigateToCardShop = true
                    Analytics.logEvent("home_first_open", parameters: nil)
                }
            }
            .onDisappear {
                if let start = screenEnterTime {
                    let duration = Date().timeIntervalSince(start)
                    Analytics.logEvent("home_screen_disappear", parameters: [
                        "duration_seconds": duration
                    ])
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCardShop) {
            CardShopView()
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    Analytics.logEvent("home_open_card_shop", parameters: nil)
                    logTimeSinceLastAction(event: "open_card_shop")
                }
        }
    }
    
    var empty_desk_user: some View {
        VStack {
            Spacer()
        }
    }
    
    var search_language_button_and_settings: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        navigateToCardShop = true
                        Analytics.logEvent("home_tap_search_language", parameters: nil)
                        logTimeSinceLastAction(event: "tap_search_language")
                    } label: {
                        VStack(alignment: .leading) {
                            ZStack {
                                Rectangle()
                                    .fill(vm.color_back_button_search_home)
                                    .frame(height: 50)
                                    .cornerRadius(30)
                                HStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundStyle(vm.color_text_search_home)
                                            .bold()
                                        Text("Search Language")
                                            .foregroundStyle(vm.color_text_search_home)
                                            .bold()
                                    }
                                    .padding(.leading)
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
        }
    }
    
    var add_collection_button: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingAddCollection = true
                    Analytics.logEvent("home_tap_add_collection_button", parameters: nil)
                    logTimeSinceLastAction(event: "tap_add_collection_button")
                    
                    // Вибрация
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 60, height: 60)
                        .background(vm.color_back_button_add_collection_home)
                        .foregroundColor(vm.color_text_button_add_collection_home)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                }
                .padding(.bottom, 85)
                .padding(.trailing, 20)
            }
        }
    }
    
    // MARK: - Analytics helper method
    private func logTimeSinceLastAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("home_action_interval", parameters: [
                "event": event,
                "interval_since_last": interval
            ])
        }
        lastActionTime = now
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
 }
 */
