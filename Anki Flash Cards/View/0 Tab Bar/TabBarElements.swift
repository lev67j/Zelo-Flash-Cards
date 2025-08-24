//
//  TabBarElements.swift
//  Boxing Train
//
//  Created by Lev Vlasov on 2025-02-03.
//

import SwiftUI
import FirebaseAnalytics

struct TabBarElements: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var appNavVM: AppNavigationVM
    @ObservedObject private var vm = DesignVM()
    
    // Для отслеживания времени на экране
    @State private var startTime: Date?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch appNavVM.selectedTab {
                    case .home:
                        HomeView(context: context)
                    case .notes:
                        NotesView()
                    case .ai_chat:
                        AIChatView(appNavVM: appNavVM, cardsText: $appNavVM.cardsTextForChat)
                    case .profile:
                        ProfileView()
                    }
                }
                
                if appNavVM.isTabBarVisible {
                    VStack {
                        Spacer()
                        
                        CustomTabBar(selectedTab: $appNavVM.selectedTab)
                            .frame(width: vm.frame_width_background_tabbar_in_tabbar_elements ?? 400)
                            .background(
                                Rectangle()
                                    .foregroundStyle(vm.color_background_tabbar_in_tabbar_elements)
                                    .opacity(vm.opacity_background_tabbar_in_tabbar_elements)
                                    .blendMode(vm.blend_mode_background_tabbar_in_tabbar_elements)
                                    .cornerRadius(vm.corner_radius_background_tabbar_in_tabbar_elements)
                                    .shadow(
                                        color: vm.shadow_color_background_tabbar_in_tabbar_elements,
                                        radius: vm.shadow_radius_background_tabbar_in_tabbar_elements,
                                        x: vm.shadow_x_offset_background_tabbar_in_tabbar_elements,
                                        y: vm.shadow_y_offset_background_tabbar_in_tabbar_elements
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: vm.corner_radius_background_tabbar_in_tabbar_elements)
                                            .stroke(
                                                vm.stroke_color_background_tabbar_in_tabbar_elements,
                                                lineWidth: vm.stroke_width_background_tabbar_in_tabbar_elements
                                            )
                                    )
                                    .padding(.top, vm.padding_top_background_tabbar_in_tabbar_elements)
                                    .padding(.bottom, vm.padding_bottom_background_tabbar_in_tabbar_elements)
                                    .padding(.leading, vm.padding_leading_background_tabbar_in_tabbar_elements)
                                    .padding(.trailing, vm.padding_trailing_background_tabbar_in_tabbar_elements)
                                    .offset(
                                        x: vm.offset_x_background_tabbar_in_tabbar_elements,
                                        y: vm.offset_y_background_tabbar_in_tabbar_elements
                                    )
                                    .ignoresSafeArea(.all)
                            )
                    }
                }
            }
            .onAppear {
                startTime = Date()
                Analytics.logEvent("tabbar_elements_appear", parameters: nil)
            }
            .onDisappear {
                Analytics.logEvent("tabbar_elements_disappear", parameters: nil)
                if let start = startTime {
                    let duration = Date().timeIntervalSince(start)
                    Analytics.logEvent("tabbar_elements_time_spent", parameters: [
                        "duration_seconds": duration
                    ])
                }
            }
        }
        .environmentObject(appNavVM)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabName
    @ObservedObject private var vm = DesignVM()
    
    var body: some View {
        VStack(spacing: vm.spacing_vstack_in_custom_tabbar) {
            Rectangle()
                .fill(vm.color_fill_divider_line_in_custom_tabbar)
                .opacity(vm.opacity_divider_line_in_custom_tabbar)
                .blendMode(vm.blend_mode_divider_line_in_custom_tabbar)
                .cornerRadius(vm.corner_radius_divider_line_in_custom_tabbar)
                .shadow(
                    color: vm.shadow_color_divider_line_in_custom_tabbar,
                    radius: vm.shadow_radius_divider_line_in_custom_tabbar,
                    x: vm.shadow_x_offset_divider_line_in_custom_tabbar,
                    y: vm.shadow_y_offset_divider_line_in_custom_tabbar
                )
                .overlay(
                    RoundedRectangle(cornerRadius: vm.corner_radius_divider_line_in_custom_tabbar)
                        .stroke(
                            vm.stroke_color_divider_line_in_custom_tabbar,
                            lineWidth: vm.stroke_width_divider_line_in_custom_tabbar
                        )
                )
                .frame(
                    width: vm.frame_width_divider_line_in_custom_tabbar,
                    height: vm.frame_height_divider_line_in_custom_tabbar
                )
                .padding(.top, vm.padding_top_divider_line_in_custom_tabbar)
                .padding(.bottom, vm.padding_bottom_divider_line_in_custom_tabbar)
                .padding(.leading, vm.padding_leading_divider_line_in_custom_tabbar)
                .padding(.trailing, vm.padding_trailing_divider_line_in_custom_tabbar)
                .offset(
                    x: vm.offset_x_divider_line_in_custom_tabbar,
                    y: vm.offset_y_divider_line_in_custom_tabbar
                )
            
            HStack(spacing: vm.spacing_hstack_in_custom_tabbar) {
                TabButton(
                    selectedTab: $selectedTab,
                    icon: "house",
                    tab: .home,
                    name: "Home",
                    select_color: vm.color_foreground_selected_home_tab_button_in_custom_tabbar,
                    no_select_color: vm.color_foreground_unselected_home_tab_button_in_custom_tabbar
                )
                TabButton(
                    selectedTab: $selectedTab,
                    icon: "note.text",
                    tab: .notes,
                    name: "Notes",
                    select_color: vm.color_foreground_selected_notes_tab_button_in_custom_tabbar,
                    no_select_color: vm.color_foreground_unselected_notes_tab_button_in_custom_tabbar
                )
                TabButton(
                    selectedTab: $selectedTab,
                    icon: "tray.full.fill",
                    tab: .ai_chat,
                    name: "AI Chat",
                    select_color: vm.color_foreground_selected_ai_chat_tab_button_in_custom_tabbar,
                    no_select_color: vm.color_foreground_unselected_ai_chat_tab_button_in_custom_tabbar
                )
                TabButton(
                    selectedTab: $selectedTab,
                    icon: "person.fill",
                    tab: .profile,
                    name: "Profile",
                    select_color: vm.color_foreground_selected_profile_tab_button_in_custom_tabbar,
                    no_select_color: vm.color_foreground_unselected_profile_tab_button_in_custom_tabbar
                )
            }
            .background(vm.color_background_hstack_in_custom_tabbar)
            .opacity(vm.opacity_hstack_in_custom_tabbar)
            .blendMode(vm.blend_mode_hstack_in_custom_tabbar)
            .cornerRadius(vm.corner_radius_hstack_in_custom_tabbar)
            .shadow(
                color: vm.shadow_color_hstack_in_custom_tabbar,
                radius: vm.shadow_radius_hstack_in_custom_tabbar,
                x: vm.shadow_x_offset_hstack_in_custom_tabbar,
                y: vm.shadow_y_offset_hstack_in_custom_tabbar
            )
            .overlay(
                RoundedRectangle(cornerRadius: vm.corner_radius_hstack_in_custom_tabbar)
                    .stroke(
                        vm.stroke_color_hstack_in_custom_tabbar,
                        lineWidth: vm.stroke_width_hstack_in_custom_tabbar
                    )
            )
            .frame(
                width: vm.frame_width_hstack_in_custom_tabbar,
                height: vm.frame_height_hstack_in_custom_tabbar
            )
            .padding(.top, vm.padding_top_hstack_in_custom_tabbar)
            .padding(.bottom, vm.padding_bottom_hstack_in_custom_tabbar)
            .padding(.leading, vm.padding_leading_hstack_in_custom_tabbar)
            .padding(.trailing, vm.padding_trailing_hstack_in_custom_tabbar)
            .offset(
                x: vm.offset_x_hstack_in_custom_tabbar,
                y: vm.offset_y_hstack_in_custom_tabbar
            )
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
            
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Логируем выбор таба в Firebase
            Analytics.logEvent("tab_selected", parameters: [
                "tab_name": "\(tab)",
                "tab_display_name": name
            ])
        } label: {
            VStack(spacing: vm.spacing_vstack_in_tab_button) {
                Image(systemName: icon)
                    .font(.system(size: vm.font_size_icon_image_in_tab_button))
                    .fontWeight(vm.font_weight_icon_image_in_tab_button)
                    .foregroundColor(selectedTab == tab ? select_color : no_select_color)
                    .opacity(vm.opacity_icon_image_in_tab_button)
                    .blendMode(vm.blend_mode_icon_image_in_tab_button)
                    .cornerRadius(vm.corner_radius_icon_image_in_tab_button)
                    .shadow(
                        color: vm.shadow_color_icon_image_in_tab_button,
                        radius: vm.shadow_radius_icon_image_in_tab_button,
                        x: vm.shadow_x_offset_icon_image_in_tab_button,
                        y: vm.shadow_y_offset_icon_image_in_tab_button
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: vm.corner_radius_icon_image_in_tab_button)
                            .stroke(
                                vm.stroke_color_icon_image_in_tab_button,
                                lineWidth: vm.stroke_width_icon_image_in_tab_button
                            )
                    )
                    .padding(.bottom, vm.padding_bottom_icon_image_in_tab_button)
                    .offset(
                        x: vm.offset_x_icon_image_in_tab_button,
                        y: vm.offset_y_icon_image_in_tab_button
                    )
                
                Text(name)
                    .font(.system(size: vm.font_size_name_text_in_tab_button))
                    .fontWeight(vm.font_weight_name_text_in_tab_button)
                    .lineSpacing(vm.line_spacing_name_text_in_tab_button)
                    .foregroundColor(selectedTab == tab ? select_color : no_select_color)
                    .opacity(vm.opacity_name_text_in_tab_button)
                    .blendMode(vm.blend_mode_name_text_in_tab_button)
                    .cornerRadius(vm.corner_radius_name_text_in_tab_button)
                    .shadow(
                        color: vm.shadow_color_name_text_in_tab_button,
                        radius: vm.shadow_radius_name_text_in_tab_button,
                        x: vm.shadow_x_offset_name_text_in_tab_button,
                        y: vm.shadow_y_offset_name_text_in_tab_button
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: vm.corner_radius_name_text_in_tab_button)
                            .stroke(
                                vm.stroke_color_name_text_in_tab_button,
                                lineWidth: vm.stroke_width_name_text_in_tab_button
                            )
                    )
                    .padding(.top, vm.padding_top_name_text_in_tab_button)
                    .padding(.bottom, vm.padding_bottom_name_text_in_tab_button)
                    .padding(.leading, vm.padding_leading_name_text_in_tab_button)
                    .padding(.trailing, vm.padding_trailing_name_text_in_tab_button)
                    .offset(
                        x: vm.offset_x_name_text_in_tab_button,
                        y: vm.offset_y_name_text_in_tab_button
                    )
            }
            .background(vm.color_background_vstack_in_tab_button)
            .opacity(vm.opacity_vstack_in_tab_button)
            .blendMode(vm.blend_mode_vstack_in_tab_button)
            .cornerRadius(vm.corner_radius_vstack_in_tab_button)
            .shadow(
                color: vm.shadow_color_vstack_in_tab_button,
                radius: vm.shadow_radius_vstack_in_tab_button,
                x: vm.shadow_x_offset_vstack_in_tab_button,
                y: vm.shadow_y_offset_vstack_in_tab_button
            )
            .overlay(
                RoundedRectangle(cornerRadius: vm.corner_radius_vstack_in_tab_button)
                    .stroke(
                        vm.stroke_color_vstack_in_tab_button,
                        lineWidth: vm.stroke_width_vstack_in_tab_button
                    )
            )
        }
        .background(vm.color_background_tab_button)
        .opacity(vm.opacity_tab_button)
        .blendMode(vm.blend_mode_tab_button)
        .cornerRadius(vm.corner_radius_tab_button)
        .shadow(
            color: vm.shadow_color_tab_button,
            radius: vm.shadow_radius_tab_button,
            x: vm.shadow_x_offset_tab_button,
            y: vm.shadow_y_offset_tab_button
        )
        .overlay(
            RoundedRectangle(cornerRadius: vm.corner_radius_tab_button)
                .stroke(
                    vm.stroke_color_tab_button,
                    lineWidth: vm.stroke_width_tab_button
                )
        )
        .frame(
            width: vm.frame_width_tab_button,
            height: vm.frame_height_tab_button
        )
        .padding(.top, vm.padding_top_tab_button)
        .padding(.bottom, vm.padding_bottom_tab_button)
        .padding(.leading, vm.padding_leading_tab_button)
        .padding(.trailing, vm.padding_trailing_tab_button)
        .offset(
            x: vm.offset_x_tab_button,
            y: vm.offset_y_tab_button
        )
    }
}

enum TabName: String {
    case home, ai_chat, notes, profile
}
