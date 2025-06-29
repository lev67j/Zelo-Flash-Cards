//
//  AIQuestView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI


struct AIQuestView: View {
    
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
                
            // Line circle day quests (how in duolingo)
            VStack {
                GeometryReader { geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 40) {
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.2)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.38)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.5)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.4)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.2)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.1)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.2)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.4)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.55)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Circle()
                                    .frame(width: 90)
                                    .padding(.trailing, geometry.size.width * 0.50)
                            }
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .padding(.top, 13)
        }
    }
}

#Preview {
    AIQuestView()
}
