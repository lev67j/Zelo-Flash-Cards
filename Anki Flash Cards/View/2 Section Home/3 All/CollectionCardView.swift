//
//  CollectionCardView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI

struct CollectionCardView: View {
    let collection: CardCollection
    @State private var isPlayButtonPressed = false
        
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                VStack(spacing: 3) {
                    HStack {
                        Text(collection.name ?? "Unnamed")
                            .font(.title3)
                            .foregroundColor(.black)
                            
                        Spacer()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(hex: "#546a50").opacity(0.3))
                    
                    HStack {
                        Text("\(collection.cards?.count ?? 0) words")
                            .foregroundColor(Color(hex: "#546a50").opacity(0.5))
                            .font(.system(size: 17))
                          
                        Spacer()
                    }
                }
                .padding(.bottom, 40)
                 
                
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

