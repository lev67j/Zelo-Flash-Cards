//
//  AIChatView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import FirebaseAnalytics

struct AIChatView: View {
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var navigate_to_AI_Level = false
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1").ignoresSafeArea()
            
            // Header "AI Chat"
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
                        
                        Text("AI Chat")
                            .font(.system(size: 17).bold())
                            .foregroundStyle(.black.opacity(0.8))
                    }
                }
            }
            
            
            // Line circle day quests
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(1..<17) { index in
                            ThemeButton(number_theme: index) {
                                logButtonTap(index: index)
                                navigate_to_AI_Level = true
                            }
                        }
                    }
                    .onAppear {
                        Analytics.logEvent("ai_quest_scrollview_appear", parameters: nil)
                    }
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 70)
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
            ThemeLevelView()
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
}

struct ThemeButton: View {
    var number_theme: Int
    var action: () -> Void
    
    @State private var isPressed = false
    @ObservedObject private var vm = DesignVM()
    
    var body: some View {
        Button {
            action()
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        } label: {
            ZStack {
                VStack(alignment: .leading) {
                    
                    VStack(spacing: 3) {
                        HStack {
                            Text("Travel \(number_theme)")
                                .font(.title3)
                                .foregroundColor(vm.color_name_language_cell_set_home)
                            
                            Spacer()
                        }
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(vm.color_line_cell_set_home)
                        
                        HStack {
                            Text("220 words")
                                .foregroundColor(vm.color_number_cards_cell_set_home)
                                .font(.system(size: 17))
                            
                            Spacer()
                        }
                    }
                    .padding(.bottom, 40)
                    
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(vm.color_calendar_text_cell_set_home)
                    }
                    
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 150)
                .background(vm.color_back_cell_set_home)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vm.color_overlay_cell_set_home, lineWidth: 8)
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 4)
                
                
            }
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
    AIChatView()
}
