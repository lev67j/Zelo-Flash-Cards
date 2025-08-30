//
//  SettingsView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.


import SwiftUI
import FirebaseAnalytics

struct SettingsView: View {
    
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                Button {
                    logAction(event: "settings_dev_text_tap")
                } label: {
                    Text("Settings in development!")
                        .foregroundStyle(.black)
                }
                .onAppear {
                    Analytics.logEvent("settings_dev_text_loaded", parameters: nil)
                }
            }
        }
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("settings_screen_appear", parameters: nil)
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("settings_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
    
    private func logAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent(event, parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent(event, parameters: nil)
        }
        lastActionTime = now
    }
}

#Preview {
    SettingsView()
}
