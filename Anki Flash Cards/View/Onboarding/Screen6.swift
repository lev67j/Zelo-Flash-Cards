//
//  ScreenSix.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Шестой экран - информация о преимуществах
struct SixthScreen: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Anki Flashcards helps you learn faster and remember everything")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Image("image for six screen") // Изображение в полном размере без искажений
                .resizable()
                .scaledToFit() // Сохраняет пропорции
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Занимает доступное пространство
            
            Button(action: {
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Let's go")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
