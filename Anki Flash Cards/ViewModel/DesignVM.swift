//
//  DesignVM.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-30.
//

/*
 Color(hex: "#F4863E") // orange
 Color(hex: "#83A5F2") // blue
 Color(hex: "#ED9BBfd") // lavanda

 Color(hex: "#ddead1") // soft green
 Color(hex: "#546a50") // dark green
 Color(hex: "#E6A7FA") // pink
 
 
 // green - pink - yellow (palette 19)
 #1E3309 // dark green
 #849A28 // green
 #E23260 // dark pink
 #F2678E // cerise pink
 #FCA9AA // soft pink
 #FBDA4B // yellow
 #FAE36F // soft yellow
*/

import SwiftUI

final class DesignVM: ObservableObject {
    
    // MARK: - TabBarElements View
    
    // Background for the tab bar (the Rectangle behind the CustomTabBar)
    @Published var color_background_tabbar_in_tabbar_elements = Color(hex: "#ddead1")
    @Published var opacity_background_tabbar_in_tabbar_elements: Double = 1.0
    @Published var blend_mode_background_tabbar_in_tabbar_elements: BlendMode = .normal
    @Published var corner_radius_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var shadow_color_background_tabbar_in_tabbar_elements = Color.black.opacity(0.0)
    @Published var shadow_radius_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var shadow_x_offset_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var shadow_y_offset_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var stroke_color_background_tabbar_in_tabbar_elements = Color.clear
    @Published var stroke_width_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var frame_width_background_tabbar_in_tabbar_elements: CGFloat? = nil
    @Published var frame_height_background_tabbar_in_tabbar_elements: CGFloat? = nil
    @Published var padding_top_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var padding_bottom_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var padding_leading_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var padding_trailing_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var offset_x_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    @Published var offset_y_background_tabbar_in_tabbar_elements: CGFloat = 0.0
    
    // MARK: - CustomTabBar View
    // Divider line (the Rectangle at the top of the CustomTabBar)
    @Published var color_fill_divider_line_in_custom_tabbar = Color(hex: "#546a50").opacity(0.05)
    @Published var opacity_divider_line_in_custom_tabbar: Double = 1.0
    @Published var blend_mode_divider_line_in_custom_tabbar: BlendMode = .normal
    @Published var corner_radius_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_color_divider_line_in_custom_tabbar = Color.black.opacity(0.0)
    @Published var shadow_radius_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_x_offset_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_y_offset_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var stroke_color_divider_line_in_custom_tabbar = Color.clear
    @Published var stroke_width_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var frame_width_divider_line_in_custom_tabbar: CGFloat = 400.0
    @Published var frame_height_divider_line_in_custom_tabbar: CGFloat = 2.0
    @Published var padding_top_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_bottom_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_leading_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_trailing_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var offset_x_divider_line_in_custom_tabbar: CGFloat = 0.0
    @Published var offset_y_divider_line_in_custom_tabbar: CGFloat = 0.0
    
    // VStack containing the divider and HStack of buttons
    @Published var spacing_vstack_in_custom_tabbar: CGFloat = 15.0
    
    // HStack containing the TabButtons
    @Published var spacing_hstack_in_custom_tabbar: CGFloat = 45.0
    @Published var color_background_hstack_in_custom_tabbar = Color.clear
    @Published var opacity_hstack_in_custom_tabbar: Double = 1.0
    @Published var blend_mode_hstack_in_custom_tabbar: BlendMode = .normal
    @Published var corner_radius_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_color_hstack_in_custom_tabbar = Color.black.opacity(0.0)
    @Published var shadow_radius_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_x_offset_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var shadow_y_offset_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var stroke_color_hstack_in_custom_tabbar = Color.clear
    @Published var stroke_width_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var frame_width_hstack_in_custom_tabbar: CGFloat? = nil
    @Published var frame_height_hstack_in_custom_tabbar: CGFloat? = nil
    @Published var padding_top_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_bottom_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_leading_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var padding_trailing_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var offset_x_hstack_in_custom_tabbar: CGFloat = 0.0
    @Published var offset_y_hstack_in_custom_tabbar: CGFloat = 0.0
    
    // MARK: - TabButton View (shared properties for all tabs; colors are per-tab below)
    // General properties for the Button itself
    @Published var color_background_tab_button = Color.clear
    @Published var opacity_tab_button: Double = 1.0
    @Published var blend_mode_tab_button: BlendMode = .normal
    @Published var corner_radius_tab_button: CGFloat = 0.0
    @Published var shadow_color_tab_button = Color.black.opacity(0.0)
    @Published var shadow_radius_tab_button: CGFloat = 0.0
    @Published var shadow_x_offset_tab_button: CGFloat = 0.0
    @Published var shadow_y_offset_tab_button: CGFloat = 0.0
    @Published var stroke_color_tab_button = Color.clear
    @Published var stroke_width_tab_button: CGFloat = 0.0
    @Published var frame_width_tab_button: CGFloat? = nil
    @Published var frame_height_tab_button: CGFloat? = nil
    @Published var padding_top_tab_button: CGFloat = 0.0
    @Published var padding_bottom_tab_button: CGFloat = 0.0
    @Published var padding_leading_tab_button: CGFloat = 0.0
    @Published var padding_trailing_tab_button: CGFloat = 0.0
    @Published var offset_x_tab_button: CGFloat = 0.0
    @Published var offset_y_tab_button: CGFloat = 0.0
    
    // VStack inside the Button label
    @Published var spacing_vstack_in_tab_button: CGFloat = 0.0
    @Published var color_background_vstack_in_tab_button = Color.clear
    @Published var opacity_vstack_in_tab_button: Double = 1.0
    @Published var blend_mode_vstack_in_tab_button: BlendMode = .normal
    @Published var corner_radius_vstack_in_tab_button: CGFloat = 0.0
    @Published var shadow_color_vstack_in_tab_button = Color.black.opacity(0.0)
    @Published var shadow_radius_vstack_in_tab_button: CGFloat = 0.0
    @Published var shadow_x_offset_vstack_in_tab_button: CGFloat = 0.0
    @Published var shadow_y_offset_vstack_in_tab_button: CGFloat = 0.0
    @Published var stroke_color_vstack_in_tab_button = Color.clear
    @Published var stroke_width_vstack_in_tab_button: CGFloat = 0.0
    
    // Image (icon) in TabButton
    @Published var font_size_icon_image_in_tab_button: CGFloat = 23.0
    @Published var font_weight_icon_image_in_tab_button: Font.Weight = .bold
    @Published var opacity_icon_image_in_tab_button: Double = 1.0
    @Published var blend_mode_icon_image_in_tab_button: BlendMode = .normal
    @Published var corner_radius_icon_image_in_tab_button: CGFloat = 0.0
    @Published var shadow_color_icon_image_in_tab_button = Color.black.opacity(0.0)
    @Published var shadow_radius_icon_image_in_tab_button: CGFloat = 0.0
    @Published var shadow_x_offset_icon_image_in_tab_button: CGFloat = 0.0
    @Published var shadow_y_offset_icon_image_in_tab_button: CGFloat = 0.0
    @Published var stroke_color_icon_image_in_tab_button = Color.clear
    @Published var stroke_width_icon_image_in_tab_button: CGFloat = 0.0
    @Published var padding_bottom_icon_image_in_tab_button: CGFloat = 1.0
    @Published var offset_x_icon_image_in_tab_button: CGFloat = 0.0
    @Published var offset_y_icon_image_in_tab_button: CGFloat = 0.0
    
    // Text (name) in TabButton
    @Published var font_size_name_text_in_tab_button: CGFloat = 13.0
    @Published var font_weight_name_text_in_tab_button: Font.Weight = .bold
    @Published var line_spacing_name_text_in_tab_button: CGFloat = 0.0
    @Published var opacity_name_text_in_tab_button: Double = 1.0
    @Published var blend_mode_name_text_in_tab_button: BlendMode = .normal
    @Published var corner_radius_name_text_in_tab_button: CGFloat = 0.0
    @Published var shadow_color_name_text_in_tab_button = Color.black.opacity(0.0)
    @Published var shadow_radius_name_text_in_tab_button: CGFloat = 0.0
    @Published var shadow_x_offset_name_text_in_tab_button: CGFloat = 0.0
    @Published var shadow_y_offset_name_text_in_tab_button: CGFloat = 0.0
    @Published var stroke_color_name_text_in_tab_button = Color.clear
    @Published var stroke_width_name_text_in_tab_button: CGFloat = 0.0
    @Published var padding_top_name_text_in_tab_button: CGFloat = 0.0
    @Published var padding_bottom_name_text_in_tab_button: CGFloat = 0.0
    @Published var padding_leading_name_text_in_tab_button: CGFloat = 0.0
    @Published var padding_trailing_name_text_in_tab_button: CGFloat = 0.0
    @Published var offset_x_name_text_in_tab_button: CGFloat = 0.0
    @Published var offset_y_name_text_in_tab_button: CGFloat = 0.0
    
    // Per-tab colors for selected and unselected states (for both icon and text, since they share)
    // Tab 1: Home
    @Published var color_foreground_selected_home_tab_button_in_custom_tabbar = Color(hex: "#546a50")
    @Published var color_foreground_unselected_home_tab_button_in_custom_tabbar = Color(hex: "#546a50").opacity(0.6)
    
    // Tab 2: Notes
    @Published var color_foreground_selected_notes_tab_button_in_custom_tabbar = Color(hex: "#546a50")
    @Published var color_foreground_unselected_notes_tab_button_in_custom_tabbar = Color(hex: "#546a50").opacity(0.6)
    
    // Tab 3: AI Chat
    @Published var color_foreground_selected_ai_chat_tab_button_in_custom_tabbar = Color(hex: "#546a50")
    @Published var color_foreground_unselected_ai_chat_tab_button_in_custom_tabbar = Color(hex: "#546a50").opacity(0.6)
    
    // Tab 4: Profile
    @Published var color_foreground_selected_profile_tab_button_in_custom_tabbar = Color(hex: "#546a50")
    @Published var color_foreground_unselected_profile_tab_button_in_custom_tabbar = Color(hex: "#546a50").opacity(0.6)
    
    
    
    
    
//--------------------------------------------------------------------------------------------------------------------------//
    
    
    
    
    
        // MARK: - HomeView
        // Background (ZStack's Color)
        @Published var color_background_zstack_in_home_view = Color(hex: "#ddead1")
        @Published var opacity_background_zstack_in_home_view: Double = 1.0
        @Published var blend_mode_background_zstack_in_home_view: BlendMode = .normal
        @Published var corner_radius_background_zstack_in_home_view: CGFloat = 0.0
        @Published var shadow_color_background_zstack_in_home_view = Color.black.opacity(0.0)
        @Published var shadow_radius_background_zstack_in_home_view: CGFloat = 0.0
        @Published var shadow_x_offset_background_zstack_in_home_view: CGFloat = 0.0
        @Published var shadow_y_offset_background_zstack_in_home_view: CGFloat = 0.0
        @Published var stroke_color_background_zstack_in_home_view = Color.clear
        @Published var stroke_width_background_zstack_in_home_view: CGFloat = 0.0
        @Published var padding_top_background_zstack_in_home_view: CGFloat = 0.0
        @Published var padding_bottom_background_zstack_in_home_view: CGFloat = 0.0
        @Published var padding_leading_background_zstack_in_home_view: CGFloat = 0.0
        @Published var padding_trailing_background_zstack_in_home_view: CGFloat = 0.0
        @Published var offset_x_background_zstack_in_home_view: CGFloat = 0.0
        @Published var offset_y_background_zstack_in_home_view: CGFloat = 0.0

        // Main content VStack
        @Published var spacing_vstack_main_content_in_home_view: CGFloat = 0.0

        // MARK: - TopBar (HStack in mainContent)
        @Published var spacing_hstack_top_bar_in_home_view: CGFloat = 12.0
        @Published var color_background_hstack_top_bar_in_home_view = Color.clear
        @Published var opacity_hstack_top_bar_in_home_view: Double = 1.0
        @Published var blend_mode_hstack_top_bar_in_home_view: BlendMode = .normal
        @Published var corner_radius_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var shadow_color_hstack_top_bar_in_home_view = Color.black.opacity(0.0)
        @Published var shadow_radius_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var shadow_x_offset_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var shadow_y_offset_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var stroke_color_hstack_top_bar_in_home_view = Color.clear
        @Published var stroke_width_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var padding_horizontal_hstack_top_bar_in_home_view: CGFloat = 16.0
        @Published var padding_bottom_hstack_top_bar_in_home_view: CGFloat = 12.0
        @Published var offset_x_hstack_top_bar_in_home_view: CGFloat = 0.0
        @Published var offset_y_hstack_top_bar_in_home_view: CGFloat = 0.0

        // MARK: - LanguageButton (Button in topBar)
        // Button container
        @Published var color_background_language_button_in_top_bar = Color.clear
        @Published var opacity_language_button_in_top_bar: Double = 1.0
        @Published var blend_mode_language_button_in_top_bar: BlendMode = .normal
        @Published var corner_radius_language_button_in_top_bar: CGFloat = 12.0
        @Published var shadow_color_language_button_in_top_bar = Color.black.opacity(0.0)
        @Published var shadow_radius_language_button_in_top_bar: CGFloat = 0.0
        @Published var shadow_x_offset_language_button_in_top_bar: CGFloat = 0.0
        @Published var shadow_y_offset_language_button_in_top_bar: CGFloat = 0.0
        @Published var stroke_color_language_button_in_top_bar = Color.clear
        @Published var stroke_width_language_button_in_top_bar: CGFloat = 0.0
        @Published var frame_width_language_button_in_top_bar: CGFloat? = nil
        @Published var frame_height_language_button_in_top_bar: CGFloat? = nil
        @Published var padding_horizontal_language_button_in_top_bar: CGFloat = 16.0
        @Published var padding_vertical_language_button_in_top_bar: CGFloat = 8.0
        @Published var offset_x_language_button_in_top_bar: CGFloat = 0.0
        @Published var offset_y_language_button_in_top_bar: CGFloat = 0.0

        // Text in LanguageButton (flag emoji)
        @Published var font_size_flag_text_in_language_button: CGFloat = 18.0
        @Published var font_weight_flag_text_in_language_button: Font.Weight = .regular
        @Published var line_spacing_flag_text_in_language_button: CGFloat = 0.0
        @Published var color_foreground_flag_text_in_language_button = Color.black
        @Published var opacity_flag_text_in_language_button: Double = 1.0
        @Published var blend_mode_flag_text_in_language_button: BlendMode = .normal
        @Published var corner_radius_flag_text_in_language_button: CGFloat = 0.0
        @Published var shadow_color_flag_text_in_language_button = Color.black.opacity(0.0)
        @Published var shadow_radius_flag_text_in_language_button: CGFloat = 0.0
        @Published var shadow_x_offset_flag_text_in_language_button: CGFloat = 0.0
        @Published var shadow_y_offset_flag_text_in_language_button: CGFloat = 0.0
        @Published var stroke_color_flag_text_in_language_button = Color.clear
        @Published var stroke_width_flag_text_in_language_button: CGFloat = 0.0
        @Published var padding_top_flag_text_in_language_button: CGFloat = 0.0
        @Published var padding_bottom_flag_text_in_language_button: CGFloat = 0.0
        @Published var padding_leading_flag_text_in_language_button: CGFloat = 0.0
        @Published var padding_trailing_flag_text_in_language_button: CGFloat = 0.0
        @Published var offset_x_flag_text_in_language_button: CGFloat = 0.0
        @Published var offset_y_flag_text_in_language_button: CGFloat = 0.0

        // MARK: - LanguageScroll (ScrollView in mainContent)
        // ScrollView container
        @Published var color_background_scroll_view_in_language_scroll: Color = Color.clear
        @Published var opacity_scroll_view_in_language_scroll: Double = 1.0
        @Published var blend_mode_scroll_view_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var shadow_color_scroll_view_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_scroll_view_in_language_scroll = Color.clear
        @Published var stroke_width_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var frame_height_scroll_view_in_language_scroll: CGFloat = 70.0
        @Published var padding_horizontal_scroll_view_in_language_scroll: CGFloat = 16.0
        @Published var offset_x_scroll_view_in_language_scroll: CGFloat = 0.0
        @Published var offset_y_scroll_view_in_language_scroll: CGFloat = 0.0

        // HStack inside ScrollView
        @Published var spacing_hstack_in_language_scroll: CGFloat = 12.0
        @Published var color_background_hstack_in_language_scroll = Color.clear
        @Published var opacity_hstack_in_language_scroll: Double = 1.0
        @Published var blend_mode_hstack_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_hstack_in_language_scroll: CGFloat = 0.0
        @Published var shadow_color_hstack_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_hstack_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_hstack_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_hstack_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_hstack_in_language_scroll = Color.clear
        @Published var stroke_width_hstack_in_language_scroll: CGFloat = 0.0
        @Published var padding_horizontal_hstack_in_language_scroll: CGFloat = 16.0
        @Published var offset_x_hstack_in_language_scroll: CGFloat = 0.0
        @Published var offset_y_hstack_in_language_scroll: CGFloat = 0.0

        // Language Button in ScrollView
        @Published var color_background_selected_language_button_in_language_scroll = Color.blue
        @Published var color_background_unselected_language_button_in_language_scroll = Color.gray.opacity(0.2)
        @Published var opacity_language_button_in_language_scroll: Double = 1.0
        @Published var blend_mode_language_button_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_language_button_in_language_scroll: CGFloat = 12.0
        @Published var shadow_color_language_button_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_language_button_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_language_button_in_language_scroll = Color.clear
        @Published var stroke_width_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_horizontal_language_button_in_language_scroll: CGFloat = 14.0
        @Published var padding_vertical_language_button_in_language_scroll: CGFloat = 6.0
        @Published var offset_x_language_button_in_language_scroll: CGFloat = 0.0
        @Published var offset_y_language_button_in_language_scroll: CGFloat = 0.0

        // HStack inside Language Button
        @Published var spacing_hstack_in_language_button_in_language_scroll: CGFloat = 6.0
        @Published var color_background_hstack_in_language_button_in_language_scroll = Color.clear
        @Published var opacity_hstack_in_language_button_in_language_scroll: Double = 1.0
        @Published var blend_mode_hstack_in_language_button_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_hstack_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_color_hstack_in_language_button_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_hstack_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_hstack_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_hstack_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_hstack_in_language_button_in_language_scroll = Color.clear
        @Published var stroke_width_hstack_in_language_button_in_language_scroll: CGFloat = 0.0

        // Flag Text in Language Button
        @Published var font_size_flag_text_in_language_button_in_language_scroll: CGFloat = 22.0
        @Published var font_weight_flag_text_in_language_button_in_language_scroll: Font.Weight = .regular
        @Published var line_spacing_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var color_foreground_flag_text_in_language_button_in_language_scroll = Color.black
        @Published var opacity_flag_text_in_language_button_in_language_scroll: Double = 1.0
        @Published var blend_mode_flag_text_in_language_button_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_color_flag_text_in_language_button_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_flag_text_in_language_button_in_language_scroll = Color.clear
        @Published var stroke_width_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_top_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_bottom_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_leading_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_trailing_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var offset_x_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var offset_y_flag_text_in_language_button_in_language_scroll: CGFloat = 0.0

        // Name Text in Language Button
        @Published var font_size_name_text_in_language_button_in_language_scroll: CGFloat = 16.0
        @Published var font_weight_name_text_in_language_button_in_language_scroll: Font.Weight = .semibold
        @Published var line_spacing_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var color_foreground_selected_name_text_in_language_button_in_language_scroll = Color.white
        @Published var color_foreground_unselected_name_text_in_language_button_in_language_scroll = Color.gray
        @Published var opacity_name_text_in_language_button_in_language_scroll: Double = 1.0
        @Published var blend_mode_name_text_in_language_button_in_language_scroll: BlendMode = .normal
        @Published var corner_radius_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_color_name_text_in_language_button_in_language_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var stroke_color_name_text_in_language_button_in_language_scroll = Color.clear
        @Published var stroke_width_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_top_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_bottom_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_leading_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var padding_trailing_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var offset_x_name_text_in_language_button_in_language_scroll: CGFloat = 0.0
        @Published var offset_y_name_text_in_language_button_in_language_scroll: CGFloat = 0.0

        // MARK: - Divider (Rectangle in mainContent)
        @Published var color_fill_divider_in_home_view = Color(hex: "#546a50").opacity(0.3)
        @Published var opacity_divider_in_home_view: Double = 0.9
        @Published var blend_mode_divider_in_home_view: BlendMode = .normal
        @Published var corner_radius_divider_in_home_view: CGFloat = 0.0
        @Published var shadow_color_divider_in_home_view = Color.black.opacity(0.0)
        @Published var shadow_radius_divider_in_home_view: CGFloat = 0.0
        @Published var shadow_x_offset_divider_in_home_view: CGFloat = 0.0
        @Published var shadow_y_offset_divider_in_home_view: CGFloat = 0.0
        @Published var stroke_color_divider_in_home_view = Color.clear
        @Published var stroke_width_divider_in_home_view: CGFloat = 0.0
        @Published var frame_height_divider_in_home_view: CGFloat = 1.0
        @Published var padding_bottom_divider_in_home_view: CGFloat = 15.0
        @Published var offset_x_divider_in_home_view: CGFloat = 0.0
        @Published var offset_y_divider_in_home_view: CGFloat = 0.0

        // MARK: - ThemeCard (VStack in mainContent)
        @Published var spacing_vstack_theme_card_in_home_view: CGFloat = 6.0
        @Published var color_background_theme_card_in_home_view = Color(hex: "#FBDA4B")
        @Published var opacity_theme_card_in_home_view: Double = 1.0
        @Published var blend_mode_theme_card_in_home_view: BlendMode = .normal
        @Published var corner_radius_theme_card_in_home_view: CGFloat = 16.0
        @Published var shadow_color_theme_card_in_home_view = Color.black.opacity(0.06)
        @Published var shadow_radius_theme_card_in_home_view: CGFloat = 4.0
        @Published var shadow_x_offset_theme_card_in_home_view: CGFloat = 0.0
        @Published var shadow_y_offset_theme_card_in_home_view: CGFloat = 2.0
        @Published var stroke_color_theme_card_in_home_view = Color.clear
        @Published var stroke_width_theme_card_in_home_view: CGFloat = 0.0
        @Published var padding_horizontal_theme_card_in_home_view: CGFloat = 16.0
        @Published var padding_vertical_theme_card_in_home_view: CGFloat = 16.0
        @Published var padding_bottom_theme_card_in_home_view: CGFloat = 10.0
        @Published var offset_x_theme_card_in_home_view: CGFloat = 0.0
        @Published var offset_y_theme_card_in_home_view: CGFloat = 0.0

        // Words Text in ThemeCard
        @Published var font_size_words_text_in_theme_card: CGFloat = 16.0
        @Published var font_weight_words_text_in_theme_card: Font.Weight = .medium
        @Published var line_spacing_words_text_in_theme_card: CGFloat = 0.0
        @Published var color_foreground_words_text_in_theme_card = Color.black
        @Published var opacity_words_text_in_theme_card: Double = 1.0
        @Published var blend_mode_words_text_in_theme_card: BlendMode = .normal
        @Published var corner_radius_words_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_color_words_text_in_theme_card = Color.black.opacity(0.0)
        @Published var shadow_radius_words_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_x_offset_words_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_y_offset_words_text_in_theme_card: CGFloat = 0.0
        @Published var stroke_color_words_text_in_theme_card = Color.clear
        @Published var stroke_width_words_text_in_theme_card: CGFloat = 0.0
        @Published var padding_top_words_text_in_theme_card: CGFloat = 0.0
        @Published var padding_bottom_words_text_in_theme_card: CGFloat = 0.0
        @Published var padding_leading_words_text_in_theme_card: CGFloat = 0.0
        @Published var padding_trailing_words_text_in_theme_card: CGFloat = 0.0
        @Published var offset_x_words_text_in_theme_card: CGFloat = 0.0
        @Published var offset_y_words_text_in_theme_card: CGFloat = 0.0

        // Title Text in ThemeCard
        @Published var font_size_title_text_in_theme_card: CGFloat = 22.0
        @Published var font_weight_title_text_in_theme_card: Font.Weight = .bold
        @Published var line_spacing_title_text_in_theme_card: CGFloat = 0.0
        @Published var color_foreground_title_text_in_theme_card = Color.black
        @Published var opacity_title_text_in_theme_card: Double = 1.0
        @Published var blend_mode_title_text_in_theme_card: BlendMode = .normal
        @Published var corner_radius_title_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_color_title_text_in_theme_card = Color.black.opacity(0.0)
        @Published var shadow_radius_title_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_x_offset_title_text_in_theme_card: CGFloat = 0.0
        @Published var shadow_y_offset_title_text_in_theme_card: CGFloat = 0.0
        @Published var stroke_color_title_text_in_theme_card = Color.clear
        @Published var stroke_width_title_text_in_theme_card: CGFloat = 0.0
        @Published var padding_top_title_text_in_theme_card: CGFloat = 0.0
        @Published var padding_bottom_title_text_in_theme_card: CGFloat = 0.0
        @Published var padding_leading_title_text_in_theme_card: CGFloat = 0.0
        @Published var padding_trailing_title_text_in_theme_card: CGFloat = 0.0
        @Published var offset_x_title_text_in_theme_card: CGFloat = 0.0
        @Published var offset_y_title_text_in_theme_card: CGFloat = 0.0

        // MARK: - LevelsScroll (ScrollView in mainContent)
        @Published var color_background_scroll_view_in_levels_scroll = Color.clear
        @Published var opacity_scroll_view_in_levels_scroll: Double = 1.0
        @Published var blend_mode_scroll_view_in_levels_scroll: BlendMode = .normal
        @Published var corner_radius_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_color_scroll_view_in_levels_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var stroke_color_scroll_view_in_levels_scroll = Color.clear
        @Published var stroke_width_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var padding_top_scroll_view_in_levels_scroll: CGFloat = 5.0
        @Published var padding_bottom_scroll_view_in_levels_scroll: CGFloat = 70.0
        @Published var offset_x_scroll_view_in_levels_scroll: CGFloat = 0.0
        @Published var offset_y_scroll_view_in_levels_scroll: CGFloat = 0.0

        // LazyVStack in LevelsScroll
        @Published var spacing_lazy_vstack_in_levels_scroll: CGFloat = 30.0
        @Published var color_background_lazy_vstack_in_levels_scroll = Color.clear
        @Published var opacity_lazy_vstack_in_levels_scroll: Double = 1.0
        @Published var blend_mode_lazy_vstack_in_levels_scroll: BlendMode = .normal
        @Published var corner_radius_lazy_vstack_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_color_lazy_vstack_in_levels_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_lazy_vstack_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_lazy_vstack_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_lazy_vstack_in_levels_scroll: CGFloat = 0.0
        @Published var stroke_color_lazy_vstack_in_levels_scroll = Color.clear
        @Published var stroke_width_lazy_vstack_in_levels_scroll: CGFloat = 0.0

        // MARK: - Separator (HStack in levelsScroll)
        @Published var spacing_hstack_separator_in_levels_scroll: CGFloat = 8.0
        @Published var color_background_hstack_separator_in_levels_scroll = Color.clear
        @Published var opacity_hstack_separator_in_levels_scroll: Double = 1.0
        @Published var blend_mode_hstack_separator_in_levels_scroll: BlendMode = .normal
        @Published var corner_radius_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_color_hstack_separator_in_levels_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var stroke_color_hstack_separator_in_levels_scroll = Color.clear
        @Published var stroke_width_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var padding_horizontal_hstack_separator_in_levels_scroll: CGFloat = 16.0
        @Published var padding_vertical_hstack_separator_in_levels_scroll: CGFloat = 10.0
        @Published var offset_x_hstack_separator_in_levels_scroll: CGFloat = 0.0
        @Published var offset_y_hstack_separator_in_levels_scroll: CGFloat = 0.0

        // Rectangles in Separator
        @Published var color_fill_rectangle_in_separator = Color(hex: "#546a50").opacity(0.3)
        @Published var opacity_rectangle_in_separator: Double = 1.0
        @Published var blend_mode_rectangle_in_separator: BlendMode = .normal
        @Published var corner_radius_rectangle_in_separator: CGFloat = 0.0
        @Published var shadow_color_rectangle_in_separator = Color.black.opacity(0.0)
        @Published var shadow_radius_rectangle_in_separator: CGFloat = 0.0
        @Published var shadow_x_offset_rectangle_in_separator: CGFloat = 0.0
        @Published var shadow_y_offset_rectangle_in_separator: CGFloat = 0.0
        @Published var stroke_color_rectangle_in_separator = Color.clear
        @Published var stroke_width_rectangle_in_separator: CGFloat = 0.0
        @Published var frame_height_rectangle_in_separator: CGFloat = 1.0
        @Published var offset_x_rectangle_in_separator: CGFloat = 0.0
        @Published var offset_y_rectangle_in_separator: CGFloat = 0.0

        // Lock Icon in Separator
        @Published var color_foreground_lock_icon_in_separator = Color.gray
        @Published var opacity_lock_icon_in_separator: Double = 1.0
        @Published var blend_mode_lock_icon_in_separator: BlendMode = .normal
        @Published var corner_radius_lock_icon_in_separator: CGFloat = 0.0
        @Published var shadow_color_lock_icon_in_separator = Color.black.opacity(0.0)
        @Published var shadow_radius_lock_icon_in_separator: CGFloat = 0.0
        @Published var shadow_x_offset_lock_icon_in_separator: CGFloat = 0.0
        @Published var shadow_y_offset_lock_icon_in_separator: CGFloat = 0.0
        @Published var stroke_color_lock_icon_in_separator = Color.clear
        @Published var stroke_width_lock_icon_in_separator: CGFloat = 0.0
        @Published var frame_width_lock_icon_in_separator: CGFloat = 14.0
        @Published var frame_height_lock_icon_in_separator: CGFloat = 14.0
        @Published var offset_x_lock_icon_in_separator: CGFloat = 0.0
        @Published var offset_y_lock_icon_in_separator: CGFloat = 0.0

        // MARK: - PillStat (HStack in topBar)
        @Published var spacing_hstack_pill_stat_in_top_bar: CGFloat = 6.0
        @Published var color_background_hstack_pill_stat_in_top_bar = Color.clear
        @Published var opacity_hstack_pill_stat_in_top_bar: Double = 1.0
        @Published var blend_mode_hstack_pill_stat_in_top_bar: BlendMode = .normal
        @Published var corner_radius_hstack_pill_stat_in_top_bar: CGFloat = 12.0
        @Published var shadow_color_hstack_pill_stat_in_top_bar = Color.black.opacity(0.0)
        @Published var shadow_radius_hstack_pill_stat_in_top_bar: CGFloat = 0.0
        @Published var shadow_x_offset_hstack_pill_stat_in_top_bar: CGFloat = 0.0
        @Published var shadow_y_offset_hstack_pill_stat_in_top_bar: CGFloat = 0.0
        @Published var stroke_color_hstack_pill_stat_in_top_bar = Color.clear
        @Published var stroke_width_hstack_pill_stat_in_top_bar: CGFloat = 0.0
        @Published var padding_horizontal_hstack_pill_stat_in_top_bar: CGFloat = 16.0
        @Published var padding_vertical_hstack_pill_stat_in_top_bar: CGFloat = 8.0
        @Published var offset_x_hstack_pill_stat_in_top_bar: CGFloat = 0.0
        @Published var offset_y_hstack_pill_stat_in_top_bar: CGFloat = 0.0

        // Icon in PillStat
        @Published var font_size_icon_in_pill_stat: CGFloat = 18.0
        @Published var font_weight_icon_in_pill_stat: Font.Weight = .bold
        @Published var color_foreground_flame_icon_in_pill_stat = Color.orange
        @Published var color_foreground_rectangle_icon_in_pill_stat = Color.gray.opacity(0.4)
        @Published var color_foreground_bolt_icon_in_pill_stat = Color.yellow
        @Published var opacity_icon_in_pill_stat: Double = 1.0
        @Published var blend_mode_icon_in_pill_stat: BlendMode = .normal
        @Published var corner_radius_icon_in_pill_stat: CGFloat = 0.0
        @Published var shadow_color_icon_in_pill_stat = Color.black.opacity(0.0)
        @Published var shadow_radius_icon_in_pill_stat: CGFloat = 0.0
        @Published var shadow_x_offset_icon_in_pill_stat: CGFloat = 0.0
        @Published var shadow_y_offset_icon_in_pill_stat: CGFloat = 0.0
        @Published var stroke_color_icon_in_pill_stat = Color.clear
        @Published var stroke_width_icon_in_pill_stat: CGFloat = 0.0
        @Published var offset_x_icon_in_pill_stat: CGFloat = 0.0
        @Published var offset_y_icon_in_pill_stat: CGFloat = 0.0

        // Value Text in PillStat
        @Published var font_size_value_text_in_pill_stat: CGFloat = 18.0
        @Published var font_weight_value_text_in_pill_stat: Font.Weight = .medium
        @Published var line_spacing_value_text_in_pill_stat: CGFloat = 0.0
        @Published var color_foreground_value_text_in_pill_stat = Color.black
        @Published var opacity_value_text_in_pill_stat: Double = 1.0
        @Published var blend_mode_value_text_in_pill_stat: BlendMode = .normal
        @Published var corner_radius_value_text_in_pill_stat: CGFloat = 0.0
        @Published var shadow_color_value_text_in_pill_stat = Color.black.opacity(0.0)
        @Published var shadow_radius_value_text_in_pill_stat: CGFloat = 0.0
        @Published var shadow_x_offset_value_text_in_pill_stat: CGFloat = 0.0
        @Published var shadow_y_offset_value_text_in_pill_stat: CGFloat = 0.0
        @Published var stroke_color_value_text_in_pill_stat = Color.clear
        @Published var stroke_width_value_text_in_pill_stat: CGFloat = 0.0
        @Published var padding_top_value_text_in_pill_stat: CGFloat = 0.0
        @Published var padding_bottom_value_text_in_pill_stat: CGFloat = 0.0
        @Published var padding_leading_value_text_in_pill_stat: CGFloat = 0.0
        @Published var padding_trailing_value_text_in_pill_stat: CGFloat = 0.0
        @Published var offset_x_value_text_in_pill_stat: CGFloat = 0.0
        @Published var offset_y_value_text_in_pill_stat: CGFloat = 0.0

        // MARK: - LevelButton
        // Button container
        @Published var color_background_level_button = Color.clear
        @Published var opacity_level_button: Double = 1.0
        @Published var blend_mode_level_button: BlendMode = .normal
        @Published var corner_radius_level_button: CGFloat = 0.0
        @Published var shadow_color_level_button = Color.black.opacity(0.0)
        @Published var shadow_radius_level_button: CGFloat = 0.0
        @Published var shadow_x_offset_level_button: CGFloat = 0.0
        @Published var shadow_y_offset_level_button: CGFloat = 0.0
        @Published var stroke_color_level_button = Color.clear
        @Published var stroke_width_level_button: CGFloat = 0.0
        @Published var frame_width_level_button: CGFloat? = nil
        @Published var frame_height_level_button: CGFloat? = nil
        @Published var padding_top_level_button: CGFloat = 0.0
        @Published var padding_bottom_level_button: CGFloat = 0.0
        @Published var padding_leading_level_button: CGFloat = 0.0
        @Published var padding_trailing_level_button: CGFloat = 0.0
        @Published var offset_x_level_button: CGFloat = 0.0 // Dynamic xOffset handled in view
        @Published var offset_y_level_button: CGFloat = 0.0

        // Progress Circle (trimmed Circle for current level)
        @Published var color_stroke_progress_circle_in_level_button = Color.blue.opacity(0.8)
        @Published var opacity_progress_circle_in_level_button: Double = 1.0
        @Published var blend_mode_progress_circle_in_level_button: BlendMode = .normal
        @Published var stroke_width_progress_circle_in_level_button: CGFloat = 5.0
        @Published var frame_width_progress_circle_in_level_button: CGFloat = 74.0
        @Published var frame_height_progress_circle_in_level_button: CGFloat = 74.0
        @Published var shadow_color_progress_circle_in_level_button = Color.black.opacity(0.0)
        @Published var shadow_radius_progress_circle_in_level_button: CGFloat = 0.0
        @Published var shadow_x_offset_progress_circle_in_level_button: CGFloat = 0.0
        @Published var shadow_y_offset_progress_circle_in_level_button: CGFloat = 0.0
        @Published var offset_x_progress_circle_in_level_button: CGFloat = 0.0
        @Published var offset_y_progress_circle_in_level_button: CGFloat = 0.0

        // Completed Circle (stroke-only Circle for completed level)
        @Published var color_stroke_completed_circle_in_level_button = Color(hex: "#FBDA4B")
        @Published var opacity_completed_circle_in_level_button: Double = 1.0
        @Published var blend_mode_completed_circle_in_level_button: BlendMode = .normal
        @Published var stroke_width_completed_circle_in_level_button: CGFloat = 5.0
        @Published var frame_width_completed_circle_in_level_button: CGFloat = 74.0
        @Published var frame_height_completed_circle_in_level_button: CGFloat = 74.0
        @Published var shadow_color_completed_circle_in_level_button = Color.black.opacity(0.0)
        @Published var shadow_radius_completed_circle_in_level_button: CGFloat = 0.0
        @Published var shadow_x_offset_completed_circle_in_level_button: CGFloat = 0.0
        @Published var shadow_y_offset_completed_circle_in_level_button: CGFloat = 0.0
        @Published var offset_x_completed_circle_in_level_button: CGFloat = 0.0
        @Published var offset_y_completed_circle_in_level_button: CGFloat = 0.0

        // Main Circle (filled Circle)
        @Published var color_fill_completed_main_circle_in_level_button = LinearGradient(
            colors: [Color(hex: "#FBDA4B"), Color(hex: "#FBDA4B")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        @Published var color_fill_uncompleted_main_circle_in_level_button = LinearGradient(
            colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.45)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        @Published var opacity_main_circle_in_level_button: Double = 1.0
        @Published var blend_mode_main_circle_in_level_button: BlendMode = .normal
        @Published var corner_radius_main_circle_in_level_button: CGFloat = 32.0
        @Published var shadow_color_main_circle_in_level_button = Color.black.opacity(0.15)
        @Published var shadow_radius_main_circle_in_level_button: CGFloat = 4.0
        @Published var shadow_x_offset_main_circle_in_level_button: CGFloat = 0.0
        @Published var shadow_y_offset_main_circle_in_level_button: CGFloat = 2.0
        @Published var stroke_color_main_circle_in_level_button = Color.white
        @Published var stroke_width_main_circle_in_level_button: CGFloat = 2.0
        @Published var frame_width_main_circle_in_level_button: CGFloat = 64.0
        @Published var frame_height_main_circle_in_level_button: CGFloat = 64.0
        @Published var offset_x_main_circle_in_level_button: CGFloat = 0.0
        @Published var offset_y_main_circle_in_level_button: CGFloat = 0.0

        // Icon in LevelButton
        @Published var font_size_icon_in_level_button: CGFloat = 26.0
        @Published var font_weight_icon_in_level_button: Font.Weight = .bold
        @Published var color_foreground_completed_icon_in_level_button = Color.white
        @Published var color_foreground_uncompleted_icon_in_level_button = Color.white.opacity(0.9)
        @Published var color_foreground_locked_icon_in_level_button = Color.white.opacity(0.45)
        @Published var opacity_icon_in_level_button: Double = 1.0
        @Published var blend_mode_icon_in_level_button: BlendMode = .normal
        @Published var corner_radius_icon_in_level_button: CGFloat = 0.0
        @Published var shadow_color_icon_in_level_button = Color.black.opacity(0.0)
        @Published var shadow_radius_icon_in_level_button: CGFloat = 0.0
        @Published var shadow_x_offset_icon_in_level_button: CGFloat = 0.0
        @Published var shadow_y_offset_icon_in_level_button: CGFloat = 0.0
        @Published var stroke_color_icon_in_level_button = Color.clear
        @Published var stroke_width_icon_in_level_button: CGFloat = 0.0
        @Published var offset_x_icon_in_level_button: CGFloat = 0.0
        @Published var offset_y_icon_in_level_button: CGFloat = 0.0

        // MARK: - SnakeLevels (VStack in levelsScroll)
        @Published var spacing_vstack_snake_levels_in_levels_scroll: CGFloat = 22.0
        @Published var color_background_vstack_snake_levels_in_levels_scroll = Color.clear
        @Published var opacity_vstack_snake_levels_in_levels_scroll: Double = 1.0
        @Published var blend_mode_vstack_snake_levels_in_levels_scroll: BlendMode = .normal
        @Published var corner_radius_vstack_snake_levels_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_color_vstack_snake_levels_in_levels_scroll = Color.black.opacity(0.0)
        @Published var shadow_radius_vstack_snake_levels_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_x_offset_vstack_snake_levels_in_levels_scroll: CGFloat = 0.0
        @Published var shadow_y_offset_vstack_snake_levels_in_levels_scroll: CGFloat = 0.0
        @Published var stroke_color_vstack_snake_levels_in_levels_scroll = Color.clear
        @Published var stroke_width_vstack_snake_levels_in_levels_scroll: CGFloat = 0.0
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
