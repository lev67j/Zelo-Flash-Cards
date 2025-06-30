//
//  DesignVM.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-30.
//

import SwiftUI

final class DesignVM: ObservableObject {
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
    
    
    
    //MARK: - Tab Bar
    // Back View
    @Published var color_back_tabbar = Color(hex: "#ddead1")
    // Tab Bar Line
    @Published var color_tab_line_tabbar = Color(hex: "#546a50").opacity(0.05)
    // Tab Button
    @Published var color_1_tab_button_selected_tabbar = Color(hex: "#546a50")
    @Published var color_1_tab_button_no_selected_tabbar = Color(hex: "#546a50").opacity(0.6)
    @Published var color_2_tab_button_selected_tabbar = Color(hex: "#546a50")
    @Published var color_2_tab_button_no_selected_tabbar = Color(hex: "#546a50").opacity(0.6)
    @Published var color_3_tab_button_selected_tabbar = Color(hex: "#546a50")
    @Published var color_3_tab_button_no_selected_tabbar = Color(hex: "#546a50").opacity(0.6)
    @Published var color_4_tab_button_selected_tabbar = Color(hex: "#546a50")
    @Published var color_4_tab_button_no_selected_tabbar = Color(hex: "#546a50").opacity(0.6)
   
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
    //MARK: - Home View
    // Back View
    @Published var color_back_home_view = Color(hex: "#ddead1")
    // Search
    @Published var color_back_button_search_home = Color.gray.opacity(0.20)
    @Published var color_text_search_home = Color.black.opacity(0.41)
    // Title "Sets"
    @Published var color_title_sets: Color = Color.black
    // Cell Sets
    @Published var color_name_language_cell_set_home = Color.black
    @Published var color_line_cell_set_home = Color(hex: "#546a50").opacity(0.3)
    @Published var color_number_cards_cell_set_home = Color(hex: "#546a50").opacity(0.5)
    @Published var color_calendar_text_cell_set_home = Color.gray
    @Published var color_back_cell_set_home = Color(hex: "#546a50").opacity(0.2)
    @Published var color_overlay_cell_set_home = Color(hex: "#546a50").opacity(0.2)
    // Add Collection Button
    @Published var color_back_button_add_collection_home = Color(hex: "#83A5F2")
    @Published var color_text_button_add_collection_home = Color.black
   
    
    //MARK: - Main Set Card View
    // Back View
    @Published var color_back_mainset_view = Color(hex: "#ddead1")
    // Header: back button + ellipsis
    @Published var color_cancel_button_mainset = Color(hex: "#546a50")
    @Published var color_ellipsis_button_mainset = Color(hex: "#546a50")
    // Bars
    @Published var color_back_bar_chart_mainset = Color(hex: "#546a50").opacity(0.1)
    // Language name | number cards
    @Published var color_language_name_mainset = Color(hex: "#546a50")
    @Published var color_line_mainset = Color(hex: "#546a50").opacity(0.3)
    @Published var color_number_cards_mainset = Color(hex: "#546a50")
    // Flash Card button
    @Published var color_text_flash_cards_button_mainset = Color(hex: "#546a50")
    @Published var color_back_flash_cards_button_mainset = Color(hex: "#546a50").opacity(0.1)
    // Sheet Edit Collection
    @Published var color_back_sheet_edit_collection_mainset = Color(hex: "#ddead1")
    // Sheet Edit Collection | "image: pencil + text: edit set"
    @Published var color_pencil_sheet_edit_collection_mainset = Color(hex: "#546a50")
    @Published var color_text_edit_set_sheet_edit_collection_mainset = Color(hex: "#546a50")
    // Sheet Edit Collection | "image: move + text: move cards"
    @Published var color_image_move_sheet_edit_collection_mainset = Color(hex: "#546a50")
    @Published var color_text_move_sheet_edit_collection_mainset = Color(hex: "#546a50")
    // Sheet Edit Collection | "image: move + text: move cards"
    @Published var color_image_trash_sheet_edit_collection_mainset = Color(hex: "#546a50")
    @Published var color_text_delete_sheet_edit_collection_mainset = Color(hex: "#546a50")
    // Sheet Flash Card
    @Published var color_back_sheet_flash_card_mainset = Color(hex: "#ddead1")
    // Sheet Flash Card | Toggle Front and Back Sides
    @Published var color_text_toggle_front_back_sheet_flash_card_mainset = Color(hex: "#546a50")
    @Published var color_tint_toggle_front_back_sheet_flash_card_mainset = Color(hex: "#546a50").opacity(0.5)
    @Published var color_back_toggle_front_back_sheet_flash_card_mainset = Color(hex: "#546a50").opacity(0.1)
    // Sheet Flash Card | Start Custom Cards "5-10-15..."
    @Published var color_text_start_custom_cards_sheet_flash_card_mainset = Color(hex: "#546a50")
    @Published var color_back_start_custom_cards_sheet_flash_card_mainset = Color(hex: "#546a50").opacity(0.1)
    // Sheet Flash Card | Sheet Start Custom Cards "5-10-15..."
    @Published var color_back_sheet_start_custom_cards_mainset = Color(hex: "#ddead1")
    @Published var color_text_select_number_cards_mainset = Color.black
    @Published var color_text_number_cards_mainset = Color.black
    @Published var color_text_button_start_mainset = Color.black
    @Published var color_back_button_start_mainset = Color(hex: "#546a50").opacity(0.7)
    // Sheet Flash Card | Start Button
    @Published var color_main_text_button_start_mainset = Color.black
    @Published var color_main_back_button_start_mainset = Color(hex: "#546a50").opacity(0.7)
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
