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
}
