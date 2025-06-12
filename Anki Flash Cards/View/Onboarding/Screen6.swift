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
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Zelo Flashcards helps you learn faster and remember everything")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .padding(.top)
            
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
                    .background(Color(hex: "#546a50"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
