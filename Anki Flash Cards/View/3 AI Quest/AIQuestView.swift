//
//  AIQuestView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import FirebaseAnalytics

struct AIQuestView: View {
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var navigate_to_AI_Level = false
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1").ignoresSafeArea()
            
            // Header "AI Quests"
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(hex: "#546a50").opacity(0.16))
                                .ignoresSafeArea()
                                .frame(height: geometry.size.height * 0.035)
                            
                            Rectangle()
                                .fill(Color(hex: "#546a50").opacity(0.38))
                                .ignoresSafeArea()
                                .frame(height: 2)
                        }
                        
                        Text("AI Quests")
                            .font(.system(size: 17).bold())
                            .foregroundStyle(.black.opacity(0.8))
                    }
                }
            }
            
            // Line circle day quests
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        ForEach(0..<10) { index in
                            DuoStyleButton(imageName: getImageName(for: index)) {
                                logButtonTap(index: index)
                                navigate_to_AI_Level = true
                            }
                            .padding(.trailing, circleOffset(for: index))
                        }
                    }
                    .padding()
                    .onAppear {
                        Analytics.logEvent("ai_quest_scrollview_appear", parameters: nil)
                    }
                }
            }
            .padding()
            .padding(.top, 13)
        }
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("ai_quest_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("ai_quest_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
        .navigationDestination(isPresented: $navigate_to_AI_Level) {
            QuestLevelView()
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func logButtonTap(index: Int) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("ai_quest_button_tap", parameters: [
                "button_index": index,
                "interval_since_last": interval
            ])
        } else {
            Analytics.logEvent("ai_quest_button_tap", parameters: [
                "button_index": index
            ])
        }
        lastActionTime = now
    }
    
    private func circleOffset(for index: Int) -> CGFloat {
        switch index {
        case 0: return -90
        case 1: return 50
        case 2: return 150
        case 3: return 50
        case 4: return -90
        case 5: return 50
        case 6: return 150
        case 7: return 50
        case 8: return -90
        case 9: return 50
        default: return 0.1
        }
    }
    
    private func getImageName(for index: Int) -> String {
        switch index {
        case 0: return "book.fill" // Book icon
        case 1: return "star.fill" // Star icon
        case 2: return "book.fill" // Book with circle
        case 3: return "star.fill" // Star with circle
        case 4: return "book.fill" // Book icon
        case 5: return "star.fill" // Star icon
        case 6: return "book.fill" // Book with circle
        case 7: return "star.fill" // Star with circle
        case 8: return "book.fill" // Book icon
        case 9: return "star.fill" // Star icon
        default: return "questionmark.circle.fill"
        }
    }
}

struct DuoStyleButton: View {
    var imageName: String
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }) {
            Image(systemName: imageName)
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 100, height: 100)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#546a50").opacity(0.5), Color(hex: "#546a50").opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#546a50").opacity(0.3), lineWidth: 4)
                        .offset(x: 5, y: 5)
                        .blur(radius: 1)
                        .background(
                            Circle()
                                .fill(Color(hex: "#546a50").opacity(0.3))
                                .offset(x: 5, y: 5)
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .scaleEffect(isPressed ? 0.9 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}


#Preview {
    AIQuestView()
}

/*
struct AIQuestView: View {
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var navigate_to_AI_Level = false
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1").ignoresSafeArea()
            
            // Header "AI Quests"
            VStack {
                GeometryReader { geometry in
                    ZStack {
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(hex: "#546a50").opacity(0.16))
                                .ignoresSafeArea()
                                .frame(height: geometry.size.height * 0.035)
                            
                            Rectangle()
                                .fill(Color(hex: "#546a50").opacity(0.38))
                                .ignoresSafeArea()
                                .frame(height: 2)
                        }
                        
                        Text("AI Quests")
                            .font(.system(size: 17).bold())
                            .foregroundStyle(.black.opacity(0.8))
                    }
                }
            }
            
            // Line circle day quests
            VStack {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 40) {
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.2)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.38)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.5)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.4)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.2)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.1)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.2)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.4)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.55)
                                }
                            }
                            
                            Button {
                                navigate_to_AI_Level = true
                                // Вибрация
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            } label: {
                                HStack {
                                    Spacer()
                                    
                                    Circle()
                                        .foregroundStyle(vm.color_button_level_quest)
                                        .frame(width: 90)
                                        .padding(.trailing, geometry.size.width * 0.5)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .padding(.top, 13)
        }
        .navigationDestination(isPresented: $navigate_to_AI_Level) {
            QuestLevelView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AIQuestView()
 }*/
