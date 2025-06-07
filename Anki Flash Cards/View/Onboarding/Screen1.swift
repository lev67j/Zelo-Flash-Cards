//
//  ScreenOne.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Первый экран онбординга
struct FirstScreen: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image("onboardingImage1")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text("Anki Flashcards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Remember More, Forget Less.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Get started")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}
