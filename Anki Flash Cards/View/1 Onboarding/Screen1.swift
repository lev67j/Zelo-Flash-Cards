//
//  ScreenOne.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Первый экран онбординга
struct FirstScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // App Icon
                    Image("icon_image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(20)
                    
                    // Onboarding image
                    Image("onboardingImage1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    
                    Text("Zelo Flashcards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#546a50"))
                    
                    Text("Remember More, Forget Less.")
                        .font(.system(size: 21).bold())
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                        
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        // Логируем нажатие
                        Analytics.logEvent("first_screen_get_started_tapped", parameters: nil)
                        
                    }) {
                        Text("Get started")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#546a50"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            startTime = Date()
            Analytics.logEvent("first_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("first_screen_disappear", parameters: nil)
            
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("first_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

/*
// Первый экран онбординга
struct FirstScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack {
            ZStack {
                Color(hex: "#ddead1")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    // App Icon
                    Image("icon_image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(20)
                    
                    // App Icon
                    Image("onboardingImage1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    
                    Text("Zelo Flashcards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#546a50"))
                    
                    Text("Remember More, Forget Less.")
                        .font(.system(size: 21).bold())
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                        
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                  
                    }) {
                        Text("Get started")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#546a50"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}
*/
