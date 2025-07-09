//
//  QuestLevelView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-07-01.
//

import SwiftUI

struct QuestLevelView: View {
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                
            }
       }
        .onAppear {
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
}

#Preview {
    QuestLevelView()
}
