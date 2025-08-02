//
//  ScreenThird.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Третий экран - выбор уровня владения языком
struct ThirdScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select your language level")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding(.top)
            
            VStack {
                LevelButton(level: "Beginner", currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                LevelButton(level: "Elementary", currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                LevelButton(level: "Intermediate", currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                LevelButton(level: "Advanced", currentPage: $currentPage)
            }
            .background(Color(hex: "#546a50").opacity(0.3))
            .cornerRadius(20)
            .padding()
            
            Spacer()
        }
        .onAppear {
            startTime = Date()
            Analytics.logEvent("third_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("third_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("third_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

private struct LevelButton: View {
    let level: String
    @Binding var currentPage: Int
    
    var body: some View {
        Button {
            // Логируем выбранный уровень
            Analytics.logEvent("language_level_selected", parameters: [
                "level": level
            ])
            
            withAnimation {
                currentPage += 1
            }
            
            // Логируем переход
            Analytics.logEvent("third_screen_next_page", parameters: [
                "new_page": currentPage
            ])
            
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        } label: {
            VStack {
                HStack {
                    ZStack {
                        HStack {
                            Image("language_level_\(level)")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(hex: "#546a50").opacity(0.4))
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text(level)
                                .foregroundColor(Color(hex: "#546a50"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.leading, 80)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(hex: "#546a50"))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

