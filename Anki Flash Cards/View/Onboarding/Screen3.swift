//
//  ScreenThird.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Третий экран - выбор уровня владения языком
struct ThirdScreen: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select your language level")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                LevelButton(level: "Beginner", currentPage: $currentPage)
                LevelButton(level: "Elementary", currentPage: $currentPage)
                LevelButton(level: "Intermediate", currentPage: $currentPage)
                LevelButton(level: "Advanced", currentPage: $currentPage)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

private struct LevelButton: View {
    let level: String
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            withAnimation {
                currentPage += 1
            }
        }) {
            Text(level)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
