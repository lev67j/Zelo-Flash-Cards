//
//  ContentView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData

struct ContentView: View {
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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#ddead1")
                .ignoresSafeArea()
                
                VStack() {
                    // Custom Header
                    HStack {
                        Image(systemName: "square.stack")
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "#E6A7FA")) // PINK HEX
                            .cornerRadius(8)
                        
                        Text("Zelo Flash Cards")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    
                    // Tabs (All, Notes, Card Shop)
                    HStack(spacing: 10) {
                        Button {
                            selectedTab = "All"
                        } label: {
                            HStack {
                                Text("All")
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "All" ? .white : .black)
                                
                                Text("65")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(selectedTab == "All" ? Color(hex: "#9DF25E") : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedTab == "All" ? Color.black : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(20)
                        }
                        
                        Button {
                            selectedTab = "Notes"
                        } label: {
                            HStack {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "Notes" ? .white : .black)
                                
                                Text("45")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(selectedTab == "Notes" ? Color(hex: "#9DF25E") : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedTab == "Notes" ? Color.black : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(20)
                        }
                        
                        Button {
                            selectedTab = "Card Shop"
                        } label: {
                            HStack {
                                Text("Shop")
                                    .font(.headline)
                                    .foregroundColor(selectedTab == "Card Shop" ? .white : .black)
                                
                                Text("10")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(selectedTab == "Card Shop" ? Color(hex: "#9DF25E") : Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedTab == "Card Shop" ? Color.black : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .cornerRadius(20)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                   
                    // Main content section
                    if selectedTab == "All" {
                        ScrollView {
                            ForEach(sortedCollections) { collection in
                                CollectionCardView(collection: collection)
                            }
                        }
                    } else if selectedTab == "Notes" {
                        NotesView()
                    } else if selectedTab == "Card Shop" {
                        CardShopView()
                    }
                }
                
                // Add collection button
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
                                    .background(Color(hex: "#E6A7FA")) // PINK HEX
                                    .cornerRadius(20)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                            }
                            .padding(.bottom, 30)
                            .padding(.trailing, 20)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
    }
}
    
struct CollectionCardView: View {
        let collection: CardCollection
        
        var body: some View {
            ZStack {
                 VStack(alignment: .leading) {
                    Text(collection.name ?? "Unnamed")
                        .font(.title3)
                        .foregroundColor(.black)
                        .padding(.bottom, 70)
                     
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        
                        Text(formattedDate(collection.creationDate))
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 150)
                .background(Color(hex: "#546a50").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 8)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 4)
                 
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink(destination: EditCollectionView(collection: collection)) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.black)
                                .bold()
                                .padding(10)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.trailing, 25)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: StatisticsView(collection: collection)) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(Color(hex: "#9DF25E")))
                                .shadow(radius: 4)
                        }
                    }
                }
                .padding(.bottom, 15)
                .padding(.trailing, 25)
            }
            
        }
        
        private func formattedDate(_ date: Date?) -> String {
            guard let date = date else { return "" }
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        
        private func priorityColor(for priority: String) -> Color {
            switch priority.lowercased() {
            case "low":
                return Color(hex: "#CDEDB3")
            case "middle":
                return Color(hex: "#CEF11B")
            case "high":
                return Color(hex: "#1D6617")
            default:
                return Color.gray
            }
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

