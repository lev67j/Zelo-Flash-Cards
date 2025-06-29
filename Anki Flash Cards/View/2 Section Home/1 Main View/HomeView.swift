//
//  HomeView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
    
    @State private var showingAddCollection = false
    @State private var selectedTab: String = "All"
    
    // Computed property to sort collections by priority
    private var sortedCollections: [CardCollection] {
        collections.sorted { (lhs, rhs) -> Bool in
            let priorityOrder = ["high": 3, "middle": 2, "low": 1]
            let lhsPriority = priorityOrder[lhs.priority?.lowercased() ?? "middle"] ?? 2
            let rhsPriority = priorityOrder[rhs.priority?.lowercased() ?? "middle"] ?? 2
            return lhsPriority > rhsPriority
        }
    }
    
    private let isFirstOpenKey = "isFirstOpen"
    @AppStorage("isFirstOpenKey") private var isFirstOpen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
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
                                        .foregroundColor(.black)
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
                    selectedTab = "Card Shop"
                }
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
                // Search
                VStack {
                    NavigationLink {
                        CardShopView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        VStack(alignment: .leading) {
                            ZStack {
                                Rectangle()
                                    .fill(.gray.opacity(0.20))
                                    .frame(height: 50)
                                    .cornerRadius(30)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundStyle(.black.opacity(0.41))
                                                .bold()
                                            
                                            Text("Search Language")
                                                .foregroundStyle(.black.opacity(0.41))
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
                if selectedTab == "All" {
                    Button(action: {
                        showingAddCollection = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: "#546a50").opacity(0.5))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                    .padding(.bottom, 85)
                    .padding(.trailing, 20)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

