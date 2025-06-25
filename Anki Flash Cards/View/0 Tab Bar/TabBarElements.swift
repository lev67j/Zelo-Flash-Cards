//
//  TabBarElements.swift
//  Boxing Train
//
//  Created by Lev Vlasov on 2025-02-03.
//

import SwiftUI

struct TabBarElements: View {
    @State private var selectedTab: TabName = .home
    @EnvironmentObject var stateProperties: StatePropertiesVM
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .notes:
                        NotesView()
                    case .day_quest:
                        DayQuestView()
                    case .profile:
                        ProfileView()
                    }
                }
                
                if stateProperties.isTabBarVisible {
                    VStack {
                        Spacer()
                        
                        CustomTabBar(selectedTab: $selectedTab)
                            .frame(width: 400) // all width in depending on the size of the iphone(quets for gpt)
                            .background(
                                Rectangle()
                                .foregroundStyle(Color(hex: "#ddead1"))
                                .ignoresSafeArea(.all)
                            )
                    }
                }
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabName
    
    var body: some View {
        VStack(spacing: 15) {
            Rectangle()
                .fill(Color(hex: "#546a50").opacity(0.05))
                .frame(height: 2)
                .frame(width: 400)
            
            HStack(spacing: 45) {
                TabButton(icon: "house", tab: .home, name: "Home", selectedTab: $selectedTab)
                TabButton(icon: "note.text", tab: .notes, name: "Notes", selectedTab: $selectedTab)
                TabButton(icon: "tray.full.fill", tab: .day_quest, name: "Day Quest", selectedTab: $selectedTab)
                TabButton(icon: "person.fill", tab: .profile, name: "Profile", selectedTab: $selectedTab)
            }
        }
    }
}

struct TabButton: View {
    let icon: String
    let tab: TabName
    let name: String
    @Binding var selectedTab: TabName
    
    var body: some View {
        Button {
            withAnimation {
                selectedTab = tab
            }
        } label: {
            VStack {
                Image(systemName: icon)
                    .bold()
                    .font(.system(size: 23))
                    .foregroundColor(selectedTab == tab ? Color(hex: "#546a50") : Color(hex: "#546a50").opacity(0.6))
                    .padding(.bottom, 1)
                
                Text(name)
                    .font(.system(size: 13)).bold()
                    .foregroundColor(selectedTab == tab ? Color(hex: "#546a50") : Color(hex: "#546a50").opacity(0.6))
            }
        }
    }
}

enum TabName {
    case home, day_quest, notes, profile
}
