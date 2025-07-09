//
//  CollectionCardView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import FirebaseAnalytics

struct CollectionCardView: View {
    
    let collection: CardCollection
    @State private var isPlayButtonPressed = false
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var screenEnterTime: Date?
        
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                VStack(spacing: 3) {
                    HStack {
                        Text(collection.name ?? "Unnamed")
                            .font(.title3)
                            .foregroundColor(vm.color_name_language_cell_set_home)
                            .onAppear {
                                Analytics.logEvent("collection_card_name_rendered", parameters: [
                                    "name": collection.name ?? "Unnamed"
                                ])
                            }
                        
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(vm.color_line_cell_set_home)
                    
                    HStack {
                        Text("\(collection.cards?.count ?? 0) words")
                            .foregroundColor(vm.color_number_cards_cell_set_home)
                            .font(.system(size: 17))
                            .onAppear {
                                Analytics.logEvent("collection_card_count_rendered", parameters: [
                                    "count": collection.cards?.count ?? 0
                                ])
                            }
                          
                        Spacer()
                    }
                }
                .padding(.bottom, 40)
                 
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(vm.color_calendar_text_cell_set_home)
                    
                    Text(formattedDate(collection.creationDate))
                        .font(.headline)
                        .foregroundColor(vm.color_calendar_text_cell_set_home)
                        .onAppear {
                            Analytics.logEvent("collection_card_date_rendered", parameters: [
                                "date": formattedDate(collection.creationDate)
                            ])
                        }
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .background(vm.color_back_cell_set_home)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(vm.color_overlay_cell_set_home, lineWidth: 8)
            )
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 4)
            .onTapGesture {
                Analytics.logEvent("collection_card_tap", parameters: [
                    "collection_name": collection.name ?? "Unnamed"
                ])
            }
            .onLongPressGesture {
                Analytics.logEvent("collection_card_long_press", parameters: [
                    "collection_name": collection.name ?? "Unnamed"
                ])
            }
        }
        .onAppear {
            screenEnterTime = Date()
            Analytics.logEvent("collection_card_screen_appear", parameters: [
                "collection_name": collection.name ?? "Unnamed"
            ])
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("collection_card_screen_disappear", parameters: [
                    "duration_seconds": duration,
                    "collection_name": collection.name ?? "Unnamed"
                ])
            }
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

/*
struct CollectionCardView: View {
    
    let collection: CardCollection
    @State private var isPlayButtonPressed = false
    
    @ObservedObject private var vm = DesignVM()
        
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                VStack(spacing: 3) {
                    HStack {
                        Text(collection.name ?? "Unnamed")
                            .font(.title3)
                            .foregroundColor(vm.color_name_language_cell_set_home)
                            
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(vm.color_line_cell_set_home)
                    
                    HStack {
                        Text("\(collection.cards?.count ?? 0) words")
                            .foregroundColor(vm.color_number_cards_cell_set_home)
                            .font(.system(size: 17))
                          
                        Spacer()
                    }
                }
                .padding(.bottom, 40)
                 
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(vm.color_calendar_text_cell_set_home)
                    
                    Text(formattedDate(collection.creationDate))
                        .font(.headline)
                        .foregroundColor(vm.color_calendar_text_cell_set_home)
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 150)
            .background(vm.color_back_cell_set_home)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(vm.color_overlay_cell_set_home, lineWidth: 8)
            )
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.vertical, 4)
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
*/
