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
            
            // Edit Collection Button
            /*VStack {
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
            .padding(.trailing, 25)*/
            
            // Statistic Button
            /*
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: StatisticsView(collection: collection)) {
                        Image(systemName: "play.fill")
                            .foregroundColor(Color(hex: "#ddead1"))
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 43, height: 43)
                            .background(isPlayButtonPressed ? Color(hex: "#546a90") : Color(hex: "#546a90").opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#546a50").opacity(0.2), lineWidth: 7)
                                   )
                            .cornerRadius(12)
                            .scaleEffect(isPlayButtonPressed ? 0.4 : 1.0)
                    }
                }
            }
            .padding(.bottom, 15)
            .padding(.trailing, 25)*/
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

