//
//  Screen10.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//
// Loader on 3 sec
// Text "Personalizing your app experience"
// Switch on Content View
// With a suggestion to select a collection of cards
// according to the language selected by the user
//
// For switch on Content View need set true on:
// UserDefaults.standard.bool(forKey: isOnboardingCompletedKey)


import SwiftUI

struct TenScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    @State private var progress: CGFloat = 0.0
    @State private var showChecks = Array(repeating: false, count: 3)
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Круговой индикатор прогресса
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(Color(hex: "#5f7e5a"))
                        .rotationEffect(Angle(degrees: -90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(width: 120, height: 120)
                .padding(.top, 40)
                
                // Заголовок
                VStack(spacing: 24) {
                    Text("Personalizing your app experience")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    
                    // Список настроек
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(zip(showChecks.indices, [
                            "Adjusting algorithm to your preferences",
                            "Optimizing deck settings",
                            "Adapting daily objectives for you"
                        ])), id: \.0) { index, text in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(showChecks[index] ? .green : .gray)
                                    .scaleEffect(showChecks[index] ? 1.1 : 0.8)
                                
                                Text(text)
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .opacity(showChecks[index] ? 1 : 0.7)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Анимация прогресса и пунктов
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 0.71
            }
            
            // Последовательное появление галочек
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) {
                    showChecks[0] = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring()) {
                    showChecks[1] = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring()) {
                    showChecks[2] = true
                }
            }
            
            // Завершение онбординга через 3 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
            }
        }
    }
}

