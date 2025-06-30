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
    @ObservedObject private var vm = DesignVM()
    
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
                        AIQuestView()
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
                                    .foregroundStyle(vm.color_back_tabbar)
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
    @ObservedObject private var vm = DesignVM()
    
    var body: some View {
        VStack(spacing: 15) {
            Rectangle()
                .fill(vm.color_tab_line_tabbar)
                .frame(height: 2)
                .frame(width: 400)
            
            HStack(spacing: 45) {
                TabButton(selectedTab: $selectedTab,
                          icon: "house",
                          tab: .home,
                          name: "Home",
                          select_color: vm.color_1_tab_button_selected_tabbar,
                          no_select_color: vm.color_1_tab_button_no_selected_tabbar)
                TabButton(selectedTab: $selectedTab,
                          icon: "note.text",
                          tab: .notes,
                          name: "Notes",
                          select_color: vm.color_2_tab_button_selected_tabbar,
                          no_select_color: vm.color_2_tab_button_no_selected_tabbar)
                TabButton(selectedTab: $selectedTab, icon: "tray.full.fill",
                          tab: .day_quest,
                          name: "AI Quest",
                          select_color: vm.color_3_tab_button_selected_tabbar,
                          no_select_color: vm.color_3_tab_button_no_selected_tabbar)
                TabButton(selectedTab: $selectedTab,
                          icon: "person.fill",
                          tab: .profile,
                          name: "Profile",
                          select_color: vm.color_4_tab_button_selected_tabbar,
                          no_select_color: vm.color_4_tab_button_no_selected_tabbar)
            }
        }
    }
}

struct TabButton: View {
    @ObservedObject private var vm = DesignVM()
    @Binding var selectedTab: TabName
     
    let icon: String
    let tab: TabName
    let name: String
    let select_color: Color
    let no_select_color: Color
    
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
                    .foregroundColor(selectedTab == tab ? select_color : no_select_color)
                    .padding(.bottom, 1)
                
                Text(name)
                    .font(.system(size: 13)).bold()
                    .foregroundColor(selectedTab == tab ? select_color : no_select_color)
            }
        }
    }
}

enum TabName {
    case home, day_quest, notes, profile
}
