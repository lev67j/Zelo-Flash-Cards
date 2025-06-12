//
//  ScreenSeven.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Седьмой экран - информация о spaced repetition
struct SeventhScreen: View {
    @Binding var currentPage: Int
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
       
            //image
            Image("image for seven screen") // Изображение в полном размере без искажений
                .resizable()
                .scaledToFit() // Сохраняет пропорции
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Занимает доступное пространство
             
            Button(action: {
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Continue")
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
