//
//  ThemeLevelView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-07-01.
//
/*
import SwiftUI
import FirebaseAnalytics

struct ThemeLevelView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Header: back button
                VStack {
                    HStack {
                        Button {
                            logBackButtonTap()
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(Color(hex: "#546a50"))
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.bottom)
                }

                Spacer()
                
                Text("Level in Development")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#546a50"))
                    .onAppear {
                        Analytics.logEvent("quest_level_text_loaded", parameters: nil)
                    }
                
                VStack(spacing: 20) {
                    Text("Support the developer")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "#546a50"))
                    
                    Text("To make the update come out faster, you can support the developer with a donation")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(Color(hex: "#546a50").opacity(0.8))
                        .padding(.horizontal, 30)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.6))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                
                Button {
                    logDonateButtonTap()
                    // Вибрация
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                } label: {
                    Text("Donate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FBDA4B"))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("quest_level_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("quest_level_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
    
    private func logDonateButtonTap() {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("quest_level_donate_button_tap", parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent("quest_level_donate_button_tap", parameters: nil)
        }
        lastActionTime = now
    }
    
    private func logBackButtonTap() {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent("quest_level_back_button_tap", parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent("quest_level_back_button_tap", parameters: nil)
        }
        lastActionTime = now
    }
}

#Preview {
    ThemeLevelView()
}
*/
