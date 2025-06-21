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
        ZStack {
            switch selectedTab {
            case .home:
                HomeView()
            case .notes:
                NotesView()
            case .libary:
                CardShopView()
           case .settings:
                HomeView()
            }
            
            if stateProperties.isTabBarVisible {
                VStack {
                    Spacer()
                    
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabName
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 50)
                .foregroundStyle(Color(hex: "#ddead1"))
                .ignoresSafeArea(.all)
            
            
            ZStack {
                Rectangle()
                    .frame(height: 50)
                    .foregroundStyle(Color(hex: "#ddead1"))
                    .ignoresSafeArea(.all)
                
                HStack(spacing: 30) { // horizontal padding
                    TabButton(icon: "house", tab: .home, selectedTab: $selectedTab)
                    TabButton(icon: "note.text", tab: .notes, selectedTab: $selectedTab)
                    TabButton(icon: "tray.full.fill", tab: .libary, selectedTab: $selectedTab)
                    TabButton(icon: "gearshape.fill", tab: .settings, selectedTab: $selectedTab)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct TabButton: View {
    let icon: String
    let tab: TabName
    @Binding var selectedTab: TabName
    
    var body: some View {
        Button {
            withAnimation {
                selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .bold()
                .font(.system(size: 23))
                .foregroundColor(selectedTab == tab ? Color(hex: "#546a50") : Color(hex: "#546a50").opacity(0.6))
                .padding()
        }
    }
}

enum TabName {
    case home, libary, notes, settings
}
