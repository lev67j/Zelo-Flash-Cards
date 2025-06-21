//
//  ScreenThird.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Третий экран - выбор уровня владения языком
struct ThirdScreen: View {
    @Binding var currentPage: Int
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select your language level")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding(.top)
            
            VStack(spacing: 10) {
                LevelButton(level: "Beginner", currentPage: $currentPage)
                LevelButton(level: "Elementary", currentPage: $currentPage)
                LevelButton(level: "Intermediate", currentPage: $currentPage)
                LevelButton(level: "Advanced", currentPage: $currentPage)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

private struct LevelButton: View {
    let level: String
    @Binding var currentPage: Int
    
    var body: some View {
        Button {
            withAnimation {
                currentPage += 1
            }
        } label: {
            HStack {
                ZStack {
                    HStack {
                        Image("language_level_\(level)")
                            .resizable()
                            .frame(width: 50, height: 50)
                        
                        Spacer()
                    }
                    
                    
                    HStack {
                        Text(level)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.leading, 80)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#9caf88"))
            .cornerRadius(10)
        }
    }
}
