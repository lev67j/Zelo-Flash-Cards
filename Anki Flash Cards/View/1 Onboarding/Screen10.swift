//
//  Screen10.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//


import SwiftUI

struct TenScreen: View {
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    @State private var progress: CGFloat = 0.0
    @State private var showChecks = Array(repeating: false, count: 3)
    
    private let isOnboardingCompletedKey = "isOnboardingCompleted"
    @AppStorage("isOnboardingCompletedKey") private var isOnboardingCompleted = false
  
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
            }
            .padding()
        }
        .onAppear {
            // Запускаем таймер для плавного обновления прогресса
            let timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                withAnimation(.linear(duration: 0.03)) {
                    if progress < 1.0 {
                        progress += 0.01 // Увеличиваем прогресс на 1% каждые 0.03 сек (100 шагов за 3 сек)
                    } else {
                        timer.invalidate() // Останавливаем таймер, когда достигаем 100%
                    }
                }
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
                withAnimation() {
                    isOnboardingCompleted = true
                }
            }
        }
    }
}
