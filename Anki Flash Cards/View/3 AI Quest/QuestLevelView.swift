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
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("Level in Development")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#546a50"))
                
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
                    // TODO: Only click test
                    
                    
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
    }
}

#Preview {
    QuestLevelView()
}
