//
//  Anki_Flash_CardsApp.swift
//  Anki Flash Cards
//
//  Created by Lev Vlasov on 2025-05-30.
//

import SwiftUI

@main
struct Anki_Flash_CardsApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.light) // Only light theme
        }
    }
}
