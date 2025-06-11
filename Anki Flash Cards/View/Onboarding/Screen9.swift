//
//  Screen9.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import UserNotifications

struct NineScreen: View {
    @Binding var currentPage: Int
    @State private var mouseOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            // Заголовок
            VStack(alignment: .leading, spacing: 10) {
                Text("Daily reminders make staying consistent easier!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                // Подпись со смайликом лампочки
                Text("💡Users who set reminders are 78% more likely to achieve a 30-day streak")
                    .font(.body)
                    .foregroundColor(Color(UIColor.systemGray))
            }
            .padding(.horizontal)
            .padding(.top)
        
            VStack {
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
            .padding(.top, 40)
            
            Spacer()

            // Кнопка "Continue" + запрос разрешения на уведомления
            Button(action: {
                requestNotificationPermission {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }) {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }

    private func requestNotificationPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
