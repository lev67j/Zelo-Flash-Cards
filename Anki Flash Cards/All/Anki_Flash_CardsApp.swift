//
//  Anki_Flash_CardsApp.swift
//  Anki Flash Cards
//
//  Created by Lev Vlasov on 2025-05-30.
//

import SwiftUI

@main
struct Anki_Flash_CardsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    @AppStorage("lastLaunchDate") private var lastLaunchDate: String = ""
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("totalTimeSpent") private var totalTimeSpent: Double = 0
    
    @State private var sessionStart: Date? = nil
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light)
                .onAppear {
                    // Запуск сессии при старте приложения
                    sessionStart = Date()
                    updateStreak()
                }
                .onChange(of: scenePhase) { newPhase, _ in
                    if newPhase == .active {
                        // Возобновляем сессию, когда приложение активируется
                        sessionStart = Date()
                    } else if newPhase == .inactive || newPhase == .background {
                        // Сохраняем время при уходе в фон или неактивности
                        if let start = sessionStart {
                            let seconds = Date().timeIntervalSince(start)
                            totalTimeSpent += seconds
                            sessionStart = nil
                        }
                    }
                }
        }
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        
        if let lastDate = formatter.date(from: lastLaunchDate) {
            let last = Calendar.current.startOfDay(for: lastDate)
            let diff = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            
            if diff == 1 {
                currentStreak += 1
            } else if diff > 1 {
                currentStreak = 1 // сбрасываем стрик, начинаем заново
            }
            // если diff == 0 — в тот же день, стрик не меняем
        } else {
            currentStreak = 1 // первый запуск
        }
        
        lastLaunchDate = formatter.string(from: today)
    }
}
