//
//  AIQuestView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI


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
}
