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

/*
struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
    
    @State private var navigateToCardShop = false
    @State private var showingAddCollection = false
    @ObservedObject private var vm = DesignVM()
    
    // Computed property to sort collections by priority
    private var sortedCollections: [CardCollection] {
        collections.sorted { lhs, rhs in
            lhs.priority > rhs.priority
        }
    }
    
    private let isFirstOpenKey = "isFirstOpen"
    @AppStorage("isFirstOpenKey") private var isFirstOpen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                vm.color_back_home_view
                    .ignoresSafeArea()
                
                VStack() {
                    
                    // Search Language
                    search_language_button_and_settings
                    
                    // Main content section
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
                                    } label: {
                                        CollectionCardView(collection: collection)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Add collection button
                add_collection_button
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                if isFirstOpen == false {
                    isFirstOpen = true
                     // In first open app show shop language
                    navigateToCardShop = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCardShop) {
            CardShopView()
                .navigationBarBackButtonHidden(true)
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
                // Search
                VStack {
                   // NavigationLink {
                     //   CardShopView()
                       //     .navigationBarBackButtonHidden(true)
                    Button {
                        navigateToCardShop = true
                    } label: {
                        VStack(alignment: .leading) {
                            ZStack {
                                Rectangle()
                                    .fill(vm.color_back_button_search_home)
                                    .frame(height: 50)
                                    .cornerRadius(30)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundStyle(vm.color_text_search_home)
                                                .bold()
                                            
                                            Text("Search Language")
                                                .foregroundStyle(vm.color_text_search_home)
                                                .bold()
                                        }
                                    }
                                    .padding(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Settings Button (Settings Screen In Development)
                /*
                 VStack {
                 NavigationLink {
                 SettingsView()
                 } label: {
                 VStack {
                 ZStack {
                 Circle()
                 .fill(.gray.opacity(0.2))
                 .frame(height: 50)
                 
                 Image(systemName: "gearshape.fill")
                 .foregroundStyle(Color(hex: "#546a50").opacity(0.7))
                 .font(.system(size: 20))
                 }
                 }
                 }
                 }
                 .padding(5)
                 */
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
*/
