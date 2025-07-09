//
//  Screen9.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import UserNotifications
import FirebaseAnalytics

struct NineScreen: View {
    @Binding var currentPage: Int
    @State private var mouseOffset: CGFloat = 0
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 24) {
            // Заголовок
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily reminders make staying consistent easier!")
                    .font(.system(size: vm.caption_font_size))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#546a50"))
                
                // Подпись со смайликом лампочки
                Text("💡Users who set reminders are 78% more likely to achieve a 30-day streak")
                    .font(.system(size: 17))
                    .foregroundColor(Color(UIColor.systemGray))
            }
            .padding()
            .padding(.bottom, 40)
    
            // Изображение алерта с тенью
            Image("alertImage")
                .resizable()
                .scaledToFit()
                .shadow(radius: 15)
                .padding(.horizontal, 50)
                .padding(.top, 30)
            
            // Анимированная мышка
            Image("mouseCursor")
                .resizable()
                .frame(width: 40, height: 40)
                .offset(y: mouseOffset)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        mouseOffset = 50
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 70)
            
            Spacer()
            
            // Кнопка "Continue" + запрос разрешения на уведомления
            Button(action: {
                // Логируем нажатие кнопки
                Analytics.logEvent("nine_screen_continue_pressed", parameters: nil)
                
                requestNotificationPermission { granted in
                    // Логируем результат запроса уведомлений
                    Analytics.logEvent("nine_screen_notification_permission", parameters: [
                        "granted": granted ? "true" : "false"
                    ])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        withAnimation {
                            currentPage += 1
                        }
                        // Логируем переход
                        Analytics.logEvent("nine_screen_next_page", parameters: [
                            "new_page": currentPage
                        ])
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
                    .cornerRadius(12)
            }
            .padding()
            .padding(.bottom)
        }
        .onAppear {
            startTime = Date()
            Analytics.logEvent("nine_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("nine_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("nine_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}

/*
struct NineScreen: View {
    @Binding var currentPage: Int
    @State private var mouseOffset: CGFloat = 0

    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 24) {
            // Заголовок
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily reminders make staying consistent easier!")
                    .font(.system(size: vm.caption_font_size))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#546a50"))
                
                // Подпись со смайликом лампочки
                Text("💡Users who set reminders are 78% more likely to achieve a 30-day streak")
                    .font(.system(size: 17))
                    .foregroundColor(Color(UIColor.systemGray))
            }
            .padding()
            .padding(.bottom, 40)
    
                // Изображение алерта с тенью
                Image("alertImage")
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 15)
                    .padding(.horizontal, 50)
                    .padding(.top, 30)
                
                // Анимированная мышка
                Image("mouseCursor")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .offset(y: mouseOffset)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            mouseOffset = 50
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 70)
            }
             
        Spacer()
        
            // Кнопка "Continue" + запрос разрешения на уведомления
            Button(action: {
                requestNotificationPermission {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        withAnimation {
                            currentPage += 1
                        }
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
                    .cornerRadius(12)
            }
            .padding()//.horizontal)
            .padding(.bottom)
        }
    }

private func requestNotificationPermission(completion: @escaping () -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        DispatchQueue.main.async {
            completion()
        }
    }
 }*/
