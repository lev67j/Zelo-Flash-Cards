//
//  ScreenEight.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import StoreKit
import FirebaseAnalytics

// Восьмой экран - запрос рейтинга
struct EighthScreen: View {
    @Binding var currentPage: Int
    @State private var showAlert = false
    
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Leave a rating to help us improve!")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .multilineTextAlignment(.leading)
                .padding()
                
            // Блок с отзывом
            VStack {
                Image("image 1 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .shadow(radius: 1)
            }
            .padding()
            .padding(.horizontal)
            
            // Блок с App Store рейтингом
            HStack {
                Image("image 2 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Логируем клик по кнопке
                Analytics.logEvent("eighth_screen_button_pressed", parameters: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation {
                        currentPage += 1
                    }
                    
                    // Логируем переход
                    Analytics.logEvent("eighth_screen_next_page", parameters: [
                        "new_page": currentPage
                    ])
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
        .onAppear {
            startTime = Date()
            Analytics.logEvent("eighth_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("eighth_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("eighth_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

/*
// Восьмой экран - запрос рейтинга
struct EighthScreen: View {
    @Binding var currentPage: Int
    @State private var showAlert = false
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Leave a rating to help us improve!")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .multilineTextAlignment(.leading)
                .padding()
                
             
            // Блок с отзывом
            VStack {
                Image("image 1 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .shadow(radius: 1)
            }
            .padding()
            .padding(.horizontal)
            
            // Блок с App Store рейтингом
            HStack {
                Image("image 2 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            }
            .padding(.horizontal)
            
            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation {
                        currentPage += 1
                    }
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
