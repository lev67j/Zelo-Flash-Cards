//
//  ScreenSeven.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Седьмой экран - информация о spaced repetition
struct SeventhScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Image("image for seven screen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: {
                // Логируем клик по кнопке
                Analytics.logEvent("seventh_screen_button_pressed", parameters: nil)
                
                withAnimation {
                    currentPage += 1
                }
                
                // Логируем переход
                Analytics.logEvent("seventh_screen_next_page", parameters: [
                    "new_page": currentPage
                ])
                
                // Вибрация
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
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
        .onAppear {
            startTime = Date()
            Analytics.logEvent("seventh_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("seventh_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("seventh_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

/*
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
                // Вибрация
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
          
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
 }*/
