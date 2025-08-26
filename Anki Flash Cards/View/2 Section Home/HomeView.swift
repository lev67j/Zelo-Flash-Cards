//
//  HomeView.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

// MARK: - HomeView
struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var vm: HomeVM
    @ObservedObject private var design = DesignVM()

    @State private var showLanguageScroll = false
    @State private var separatorYs: [Int: CGFloat] = [:]
    @State private var themeCardAnchorY: CGFloat = 0

    init(context: NSManagedObjectContext) {
        self.vm = HomeVM(context: context)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .background(design.color_background_zstack_in_home_view)
                    .opacity(design.opacity_background_zstack_in_home_view)
                    .blendMode(design.blend_mode_background_zstack_in_home_view)
                    .cornerRadius(design.corner_radius_background_zstack_in_home_view)
                    .shadow(
                        color: design.shadow_color_background_zstack_in_home_view,
                        radius: design.shadow_radius_background_zstack_in_home_view,
                        x: design.shadow_x_offset_background_zstack_in_home_view,
                        y: design.shadow_y_offset_background_zstack_in_home_view
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_background_zstack_in_home_view)
                            .stroke(
                                design.stroke_color_background_zstack_in_home_view,
                                lineWidth: design.stroke_width_background_zstack_in_home_view
                            )
                    )
                    .padding(.top, design.padding_top_background_zstack_in_home_view)
                    .padding(.bottom, design.padding_bottom_background_zstack_in_home_view)
                    .padding(.leading, design.padding_leading_background_zstack_in_home_view)
                    .padding(.trailing, design.padding_trailing_background_zstack_in_home_view)
                    .offset(
                        x: design.offset_x_background_zstack_in_home_view,
                        y: design.offset_y_background_zstack_in_home_view
                    )
                    .ignoresSafeArea()
                mainContent
            }
            .sheet(isPresented: $vm.showingAddCollection) {
                AddCollectionView()
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
                    .onAppear {
                        Analytics.logEvent("home_open_add_collection_sheet", parameters: nil)
                        vm.logTimeSinceLastAction(event: "open_add_collection_sheet")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .onAppear {
                vm.screenEnterTime = Date()
                vm.lastActionTime = Date()
                Analytics.logEvent("home_screen_appear", parameters: ["language": vm.selectedLanguage])
                if !vm.isFirstOpen {
                    vm.isFirstOpen = true
                    Analytics.logEvent("home_first_open", parameters: ["language": vm.selectedLanguage])
                }
            }
            .onDisappear {
                if let start = vm.screenEnterTime {
                    let duration = Date().timeIntervalSince(start)
                    Analytics.logEvent("home_screen_disappear", parameters: [
                        "duration_seconds": duration,
                        "language": vm.selectedLanguage
                    ])
                }
            }
            .navigationDestination(isPresented: $vm.navigateToFlashCard) {
                navigationDestinationView
            }
            .onPreferenceChange(ThemeCardAnchorKey.self) { y in
                themeCardAnchorY = y
                recomputeActiveTheme()
            }
            .onPreferenceChange(ThemeSeparatorKey.self) { arr in
                for item in arr { separatorYs[item.index] = item.y }
                recomputeActiveTheme()
            }
            .onChange(of: vm.currentThemeIndex) { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }

    // MARK: - Subviews
    private var mainContent: some View {
        VStack(spacing: design.spacing_vstack_main_content_in_home_view) {
            topBar
            languageScroll
            divider
            themeCard
            levelsScroll
        }
    }

    private var topBar: some View {
        HStack(spacing: design.spacing_hstack_top_bar_in_home_view) {
            languageButton
            pillStat(icon: "flame.fill", value: vm.currentStreak)
            pillStat(icon: "rectangle.on.rectangle.fill", value: vm.studiedCardsCount)
            pillStat(icon: "bolt.fill", value: vm.starsCount)
        }
        .background(design.color_background_hstack_top_bar_in_home_view)
        .opacity(design.opacity_hstack_top_bar_in_home_view)
        .blendMode(design.blend_mode_hstack_top_bar_in_home_view)
        .cornerRadius(design.corner_radius_hstack_top_bar_in_home_view)
        .shadow(
            color: design.shadow_color_hstack_top_bar_in_home_view,
            radius: design.shadow_radius_hstack_top_bar_in_home_view,
            x: design.shadow_x_offset_hstack_top_bar_in_home_view,
            y: design.shadow_y_offset_hstack_top_bar_in_home_view
        )
        .overlay(
            RoundedRectangle(cornerRadius: design.corner_radius_hstack_top_bar_in_home_view)
                .stroke(
                    design.stroke_color_hstack_top_bar_in_home_view,
                    lineWidth: design.stroke_width_hstack_top_bar_in_home_view
                )
        )
        .padding(.horizontal, design.padding_horizontal_hstack_top_bar_in_home_view)
        .padding(.bottom, design.padding_bottom_hstack_top_bar_in_home_view)
        .offset(
            x: design.offset_x_hstack_top_bar_in_home_view,
            y: design.offset_y_hstack_top_bar_in_home_view
        )
    }

    private var languageButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                showLanguageScroll.toggle()
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            pill {
                Text(vm.flagForLanguage(vm.selectedLanguage))
                    .font(.system(size: design.font_size_flag_text_in_language_button))
                    .fontWeight(design.font_weight_flag_text_in_language_button)
                    .lineSpacing(design.line_spacing_flag_text_in_language_button)
                    .foregroundColor(design.color_foreground_flag_text_in_language_button)
                    .opacity(design.opacity_flag_text_in_language_button)
                    .blendMode(design.blend_mode_flag_text_in_language_button)
                    .cornerRadius(design.corner_radius_flag_text_in_language_button)
                    .shadow(
                        color: design.shadow_color_flag_text_in_language_button,
                        radius: design.shadow_radius_flag_text_in_language_button,
                        x: design.shadow_x_offset_flag_text_in_language_button,
                        y: design.shadow_y_offset_flag_text_in_language_button
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_flag_text_in_language_button)
                            .stroke(
                                design.stroke_color_flag_text_in_language_button,
                                lineWidth: design.stroke_width_flag_text_in_language_button
                            )
                    )
                    .padding(.top, design.padding_top_flag_text_in_language_button)
                    .padding(.bottom, design.padding_bottom_flag_text_in_language_button)
                    .padding(.leading, design.padding_leading_flag_text_in_language_button)
                    .padding(.trailing, design.padding_trailing_flag_text_in_language_button)
                    .offset(
                        x: design.offset_x_flag_text_in_language_button,
                        y: design.offset_y_flag_text_in_language_button
                    )
            }
        }
        .background(design.color_background_language_button_in_top_bar)
        .opacity(design.opacity_language_button_in_top_bar)
        .blendMode(design.blend_mode_language_button_in_top_bar)
        .cornerRadius(design.corner_radius_language_button_in_top_bar)
        .shadow(
            color: design.shadow_color_language_button_in_top_bar,
            radius: design.shadow_radius_language_button_in_top_bar,
            x: design.shadow_x_offset_language_button_in_top_bar,
            y: design.shadow_y_offset_language_button_in_top_bar
        )
        .overlay(
            RoundedRectangle(cornerRadius: design.corner_radius_language_button_in_top_bar)
                .stroke(
                    design.stroke_color_language_button_in_top_bar,
                    lineWidth: design.stroke_width_language_button_in_top_bar
                )
        )
        .frame(
            width: design.frame_width_language_button_in_top_bar,
            height: design.frame_height_language_button_in_top_bar
        )
        .offset(
            x: design.offset_x_language_button_in_top_bar,
            y: design.offset_y_language_button_in_top_bar
        )
    }

    private var languageScroll: some View {
        Group {
            if showLanguageScroll {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: design.spacing_hstack_in_language_scroll) {
                        ForEach(vm.availableLanguages) { language in
                            Button {
                                vm.switchLanguage(to: language.name)
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    showLanguageScroll = false
                                }
                            } label: {
                                HStack(spacing: design.spacing_hstack_in_language_button_in_language_scroll) {
                                    Text(language.flag)
                                        .font(.system(size: design.font_size_flag_text_in_language_button_in_language_scroll))
                                        .fontWeight(design.font_weight_flag_text_in_language_button_in_language_scroll)
                                        .lineSpacing(design.line_spacing_flag_text_in_language_button_in_language_scroll)
                                        .foregroundColor(design.color_foreground_flag_text_in_language_button_in_language_scroll)
                                        .opacity(design.opacity_flag_text_in_language_button_in_language_scroll)
                                        .blendMode(design.blend_mode_flag_text_in_language_button_in_language_scroll)
                                        .cornerRadius(design.corner_radius_flag_text_in_language_button_in_language_scroll)
                                        .shadow(
                                            color: design.shadow_color_flag_text_in_language_button_in_language_scroll,
                                            radius: design.shadow_radius_flag_text_in_language_button_in_language_scroll,
                                            x: design.shadow_x_offset_flag_text_in_language_button_in_language_scroll,
                                            y: design.shadow_y_offset_flag_text_in_language_button_in_language_scroll
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: design.corner_radius_flag_text_in_language_button_in_language_scroll)
                                                .stroke(
                                                    design.stroke_color_flag_text_in_language_button_in_language_scroll,
                                                    lineWidth: design.stroke_width_flag_text_in_language_button_in_language_scroll
                                                )
                                        )
                                        .padding(.top, design.padding_top_flag_text_in_language_button_in_language_scroll)
                                        .padding(.bottom, design.padding_bottom_flag_text_in_language_button_in_language_scroll)
                                        .padding(.leading, design.padding_leading_flag_text_in_language_button_in_language_scroll)
                                        .padding(.trailing, design.padding_trailing_flag_text_in_language_button_in_language_scroll)
                                        .offset(
                                            x: design.offset_x_flag_text_in_language_button_in_language_scroll,
                                            y: design.offset_y_flag_text_in_language_button_in_language_scroll
                                        )
                                    Text(language.name)
                                        .font(.system(size: design.font_size_name_text_in_language_button_in_language_scroll))
                                        .fontWeight(design.font_weight_name_text_in_language_button_in_language_scroll)
                                        .lineSpacing(design.line_spacing_name_text_in_language_button_in_language_scroll)
                                        .foregroundColor(vm.selectedLanguage == language.name ? design.color_foreground_selected_name_text_in_language_button_in_language_scroll : design.color_foreground_unselected_name_text_in_language_button_in_language_scroll)
                                        .opacity(design.opacity_name_text_in_language_button_in_language_scroll)
                                        .blendMode(design.blend_mode_name_text_in_language_button_in_language_scroll)
                                        .cornerRadius(design.corner_radius_name_text_in_language_button_in_language_scroll)
                                        .shadow(
                                            color: design.shadow_color_name_text_in_language_button_in_language_scroll,
                                            radius: design.shadow_radius_name_text_in_language_button_in_language_scroll,
                                            x: design.shadow_x_offset_name_text_in_language_button_in_language_scroll,
                                            y: design.shadow_y_offset_name_text_in_language_button_in_language_scroll
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: design.corner_radius_name_text_in_language_button_in_language_scroll)
                                                .stroke(
                                                    design.stroke_color_name_text_in_language_button_in_language_scroll,
                                                    lineWidth: design.stroke_width_name_text_in_language_button_in_language_scroll
                                                )
                                        )
                                        .padding(.top, design.padding_top_name_text_in_language_button_in_language_scroll)
                                        .padding(.bottom, design.padding_bottom_name_text_in_language_button_in_language_scroll)
                                        .padding(.leading, design.padding_leading_name_text_in_language_button_in_language_scroll)
                                        .padding(.trailing, design.padding_trailing_name_text_in_language_button_in_language_scroll)
                                        .offset(
                                            x: design.offset_x_name_text_in_language_button_in_language_scroll,
                                            y: design.offset_y_name_text_in_language_button_in_language_scroll
                                        )
                                }
                                .background(design.color_background_hstack_in_language_button_in_language_scroll)
                                .opacity(design.opacity_hstack_in_language_button_in_language_scroll)
                                .blendMode(design.blend_mode_hstack_in_language_button_in_language_scroll)
                                .cornerRadius(design.corner_radius_hstack_in_language_button_in_language_scroll)
                                .shadow(
                                    color: design.shadow_color_hstack_in_language_button_in_language_scroll,
                                    radius: design.shadow_radius_hstack_in_language_button_in_language_scroll,
                                    x: design.shadow_x_offset_hstack_in_language_button_in_language_scroll,
                                    y: design.shadow_y_offset_hstack_in_language_button_in_language_scroll
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: design.corner_radius_hstack_in_language_button_in_language_scroll)
                                        .stroke(
                                            design.stroke_color_hstack_in_language_button_in_language_scroll,
                                            lineWidth: design.stroke_width_hstack_in_language_button_in_language_scroll
                                        )
                                )
                            }
                            .background(vm.selectedLanguage == language.name ? design.color_background_selected_language_button_in_language_scroll : design.color_background_unselected_language_button_in_language_scroll)
                            .opacity(design.opacity_language_button_in_language_scroll)
                            .blendMode(design.blend_mode_language_button_in_language_scroll)
                            .cornerRadius(design.corner_radius_language_button_in_language_scroll)
                            .shadow(
                                color: design.shadow_color_language_button_in_language_scroll,
                                radius: design.shadow_radius_language_button_in_language_scroll,
                                x: design.shadow_x_offset_language_button_in_language_scroll,
                                y: design.shadow_y_offset_language_button_in_language_scroll
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: design.corner_radius_language_button_in_language_scroll)
                                    .stroke(
                                        design.stroke_color_language_button_in_language_scroll,
                                        lineWidth: design.stroke_width_language_button_in_language_scroll
                                    )
                            )
                            .padding(.horizontal, design.padding_horizontal_language_button_in_language_scroll)
                            .padding(.vertical, design.padding_vertical_language_button_in_language_scroll)
                            .offset(
                                x: design.offset_x_language_button_in_language_scroll,
                                y: design.offset_y_language_button_in_language_scroll
                            )
                        }
                    }
                    .background(design.color_background_hstack_in_language_scroll)
                    .opacity(design.opacity_hstack_in_language_scroll)
                    .blendMode(design.blend_mode_hstack_in_language_scroll)
                    .cornerRadius(design.corner_radius_hstack_in_language_scroll)
                    .shadow(
                        color: design.shadow_color_hstack_in_language_scroll,
                        radius: design.shadow_radius_hstack_in_language_scroll,
                        x: design.shadow_x_offset_hstack_in_language_scroll,
                        y: design.shadow_y_offset_hstack_in_language_scroll
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_hstack_in_language_scroll)
                            .stroke(
                                design.stroke_color_hstack_in_language_scroll,
                                lineWidth: design.stroke_width_hstack_in_language_scroll
                            )
                    )
                    .padding(.horizontal, design.padding_horizontal_hstack_in_language_scroll)
                }
                .background(design.color_background_scroll_view_in_language_scroll)
                .opacity(design.opacity_scroll_view_in_language_scroll)
                .blendMode(design.blend_mode_scroll_view_in_language_scroll)
                .cornerRadius(design.corner_radius_scroll_view_in_language_scroll)
                .shadow(
                    color: design.shadow_color_scroll_view_in_language_scroll,
                    radius: design.shadow_radius_scroll_view_in_language_scroll,
                    x: design.shadow_x_offset_scroll_view_in_language_scroll,
                    y: design.shadow_y_offset_scroll_view_in_language_scroll
                )
                .overlay(
                    RoundedRectangle(cornerRadius: design.corner_radius_scroll_view_in_language_scroll)
                        .stroke(
                            design.stroke_color_scroll_view_in_language_scroll,
                            lineWidth: design.stroke_width_scroll_view_in_language_scroll
                        )
                )
                .frame(height: design.frame_height_scroll_view_in_language_scroll)
                .offset(
                    x: design.offset_x_scroll_view_in_language_scroll,
                    y: design.offset_y_scroll_view_in_language_scroll
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(design.color_fill_divider_in_home_view)
            .opacity(design.opacity_divider_in_home_view)
            .blendMode(design.blend_mode_divider_in_home_view)
            .cornerRadius(design.corner_radius_divider_in_home_view)
            .shadow(
                color: design.shadow_color_divider_in_home_view,
                radius: design.shadow_radius_divider_in_home_view,
                x: design.shadow_x_offset_divider_in_home_view,
                y: design.shadow_y_offset_divider_in_home_view
            )
            .overlay(
                RoundedRectangle(cornerRadius: design.corner_radius_divider_in_home_view)
                    .stroke(
                        design.stroke_color_divider_in_home_view,
                        lineWidth: design.stroke_width_divider_in_home_view
                    )
            )
            .frame(height: design.frame_height_divider_in_home_view)
            .padding(.bottom, design.padding_bottom_divider_in_home_view)
            .offset(
                x: design.offset_x_divider_in_home_view,
                y: design.offset_y_divider_in_home_view
            )
    }

    private var themeCard: some View {
        Group {
            if let currentTheme = vm.currentTheme {
                VStack(alignment: .leading, spacing: design.spacing_vstack_theme_card_in_home_view) {
                    Text("Words \(currentTheme.cards.count)")
                        .font(.system(size: design.font_size_words_text_in_theme_card))
                        .fontWeight(design.font_weight_words_text_in_theme_card)
                        .lineSpacing(design.line_spacing_words_text_in_theme_card)
                        .foregroundColor(design.color_foreground_words_text_in_theme_card)
                        .opacity(design.opacity_words_text_in_theme_card)
                        .blendMode(design.blend_mode_words_text_in_theme_card)
                        .cornerRadius(design.corner_radius_words_text_in_theme_card)
                        .shadow(
                            color: design.shadow_color_words_text_in_theme_card,
                            radius: design.shadow_radius_words_text_in_theme_card,
                            x: design.shadow_x_offset_words_text_in_theme_card,
                            y: design.shadow_y_offset_words_text_in_theme_card
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: design.corner_radius_words_text_in_theme_card)
                                .stroke(
                                    design.stroke_color_words_text_in_theme_card,
                                    lineWidth: design.stroke_width_words_text_in_theme_card
                                )
                        )
                        .padding(.top, design.padding_top_words_text_in_theme_card)
                        .padding(.bottom, design.padding_bottom_words_text_in_theme_card)
                        .padding(.leading, design.padding_leading_words_text_in_theme_card)
                        .padding(.trailing, design.padding_trailing_words_text_in_theme_card)
                        .offset(
                            x: design.offset_x_words_text_in_theme_card,
                            y: design.offset_y_words_text_in_theme_card
                        )
                    Text(currentTheme.title)
                        .font(.system(size: design.font_size_title_text_in_theme_card))
                        .fontWeight(design.font_weight_title_text_in_theme_card)
                        .lineSpacing(design.line_spacing_title_text_in_theme_card)
                        .foregroundColor(design.color_foreground_title_text_in_theme_card)
                        .opacity(design.opacity_title_text_in_theme_card)
                        .blendMode(design.blend_mode_title_text_in_theme_card)
                        .cornerRadius(design.corner_radius_title_text_in_theme_card)
                        .shadow(
                            color: design.shadow_color_title_text_in_theme_card,
                            radius: design.shadow_radius_title_text_in_theme_card,
                            x: design.shadow_x_offset_title_text_in_theme_card,
                            y: design.shadow_y_offset_title_text_in_theme_card
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: design.corner_radius_title_text_in_theme_card)
                                .stroke(
                                    design.stroke_color_title_text_in_theme_card,
                                    lineWidth: design.stroke_width_title_text_in_theme_card
                                )
                        )
                        .padding(.top, design.padding_top_title_text_in_theme_card)
                        .padding(.bottom, design.padding_bottom_title_text_in_theme_card)
                        .padding(.leading, design.padding_leading_title_text_in_theme_card)
                        .padding(.trailing, design.padding_trailing_title_text_in_theme_card)
                        .offset(
                            x: design.offset_x_title_text_in_theme_card,
                            y: design.offset_y_title_text_in_theme_card
                        )
                }
                .padding(.horizontal, design.padding_horizontal_theme_card_in_home_view)
                .padding(.vertical, design.padding_vertical_theme_card_in_home_view)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: design.corner_radius_theme_card_in_home_view)
                        .fill(design.color_background_theme_card_in_home_view)
                        .shadow(
                            color: design.shadow_color_theme_card_in_home_view,
                            radius: design.shadow_radius_theme_card_in_home_view,
                            x: design.shadow_x_offset_theme_card_in_home_view,
                            y: design.shadow_y_offset_theme_card_in_home_view
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: design.corner_radius_theme_card_in_home_view)
                                .stroke(
                                    design.stroke_color_theme_card_in_home_view,
                                    lineWidth: design.stroke_width_theme_card_in_home_view
                                )
                        )
                )
                .padding(.horizontal, design.padding_horizontal_theme_card_in_home_view)
                .padding(.bottom, design.padding_bottom_theme_card_in_home_view)
                .offset(
                    x: design.offset_x_theme_card_in_home_view,
                    y: design.offset_y_theme_card_in_home_view
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: ThemeCardAnchorKey.self,
                                        value: proxy.frame(in: .named("scrollSpace")).midY)
                    }
                )
                .animation(.easeInOut(duration: 0.15), value: currentTheme.title)
            }
        }
    }

    private var levelsScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: design.spacing_lazy_vstack_in_levels_scroll) {
                ForEach(vm.themes.indices, id: \.self) { themeIndex in
                    let theme = vm.themes[themeIndex]
                    snakeLevels(for: theme, themeIndex: themeIndex)
                    separator(themeIndex: themeIndex)
                }
            }
            .background(design.color_background_lazy_vstack_in_levels_scroll)
            .opacity(design.opacity_lazy_vstack_in_levels_scroll)
            .blendMode(design.blend_mode_lazy_vstack_in_levels_scroll)
            .cornerRadius(design.corner_radius_lazy_vstack_in_levels_scroll)
            .shadow(
                color: design.shadow_color_lazy_vstack_in_levels_scroll,
                radius: design.shadow_radius_lazy_vstack_in_levels_scroll,
                x: design.shadow_x_offset_lazy_vstack_in_levels_scroll,
                y: design.shadow_y_offset_lazy_vstack_in_levels_scroll
            )
            .overlay(
                RoundedRectangle(cornerRadius: design.corner_radius_lazy_vstack_in_levels_scroll)
                    .stroke(
                        design.stroke_color_lazy_vstack_in_levels_scroll,
                        lineWidth: design.stroke_width_lazy_vstack_in_levels_scroll
                    )
            )
            .padding(.top, design.padding_top_scroll_view_in_levels_scroll)
            .padding(.bottom, design.padding_bottom_scroll_view_in_levels_scroll)
        }
        .background(design.color_background_scroll_view_in_levels_scroll)
        .opacity(design.opacity_scroll_view_in_levels_scroll)
        .blendMode(design.blend_mode_scroll_view_in_levels_scroll)
        .cornerRadius(design.corner_radius_scroll_view_in_levels_scroll)
        .shadow(
            color: design.shadow_color_scroll_view_in_levels_scroll,
            radius: design.shadow_radius_scroll_view_in_levels_scroll,
            x: design.shadow_x_offset_scroll_view_in_levels_scroll,
            y: design.shadow_y_offset_scroll_view_in_levels_scroll
        )
        .overlay(
            RoundedRectangle(cornerRadius: design.corner_radius_scroll_view_in_levels_scroll)
                .stroke(
                    design.stroke_color_scroll_view_in_levels_scroll,
                    lineWidth: design.stroke_width_scroll_view_in_levels_scroll
                )
        )
        .offset(
            x: design.offset_x_scroll_view_in_levels_scroll,
            y: design.offset_y_scroll_view_in_levels_scroll
        )
        .coordinateSpace(name: "scrollSpace")
        .onAppear {
            Analytics.logEvent("ai_quest_scrollview_appear", parameters: nil)
        }
    }

    private func separator(themeIndex: Int) -> some View {
        HStack(spacing: design.spacing_hstack_separator_in_levels_scroll) {
            Rectangle()
                .fill(design.color_fill_rectangle_in_separator)
                .opacity(design.opacity_rectangle_in_separator)
                .blendMode(design.blend_mode_rectangle_in_separator)
                .cornerRadius(design.corner_radius_rectangle_in_separator)
                .shadow(
                    color: design.shadow_color_rectangle_in_separator,
                    radius: design.shadow_radius_rectangle_in_separator,
                    x: design.shadow_x_offset_rectangle_in_separator,
                    y: design.shadow_y_offset_rectangle_in_separator
                )
                .overlay(
                    RoundedRectangle(cornerRadius: design.corner_radius_rectangle_in_separator)
                        .stroke(
                            design.stroke_color_rectangle_in_separator,
                            lineWidth: design.stroke_width_rectangle_in_separator
                        )
                )
                .frame(height: design.frame_height_rectangle_in_separator)
                .offset(
                    x: design.offset_x_rectangle_in_separator,
                    y: design.offset_y_rectangle_in_separator
                )
            Image(systemName: vm.isThemeUnlocked(themeIndex: themeIndex) ? "lock.open.fill" : "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: design.frame_width_lock_icon_in_separator, height: design.frame_height_lock_icon_in_separator)
                .foregroundColor(design.color_foreground_lock_icon_in_separator)
                .opacity(design.opacity_lock_icon_in_separator)
                .blendMode(design.blend_mode_lock_icon_in_separator)
                .cornerRadius(design.corner_radius_lock_icon_in_separator)
                .shadow(
                    color: design.shadow_color_lock_icon_in_separator,
                    radius: design.shadow_radius_lock_icon_in_separator,
                    x: design.shadow_x_offset_lock_icon_in_separator,
                    y: design.shadow_y_offset_lock_icon_in_separator
                )
                .overlay(
                    RoundedRectangle(cornerRadius: design.corner_radius_lock_icon_in_separator)
                        .stroke(
                            design.stroke_color_lock_icon_in_separator,
                            lineWidth: design.stroke_width_lock_icon_in_separator
                        )
                )
                .offset(
                    x: design.offset_x_lock_icon_in_separator,
                    y: design.offset_y_lock_icon_in_separator
                )
            Rectangle()
                .fill(design.color_fill_rectangle_in_separator)
                .opacity(design.opacity_rectangle_in_separator)
                .blendMode(design.blend_mode_rectangle_in_separator)
                .cornerRadius(design.corner_radius_rectangle_in_separator)
                .shadow(
                    color: design.shadow_color_rectangle_in_separator,
                    radius: design.shadow_radius_rectangle_in_separator,
                    x: design.shadow_x_offset_rectangle_in_separator,
                    y: design.shadow_y_offset_rectangle_in_separator
                )
                .overlay(
                    RoundedRectangle(cornerRadius: design.corner_radius_rectangle_in_separator)
                        .stroke(
                            design.stroke_color_rectangle_in_separator,
                            lineWidth: design.stroke_width_rectangle_in_separator
                        )
                )
                .frame(height: design.frame_height_rectangle_in_separator)
                .offset(
                    x: design.offset_x_rectangle_in_separator,
                    y: design.offset_y_rectangle_in_separator
                )
        }
        .background(design.color_background_hstack_separator_in_levels_scroll)
        .opacity(design.opacity_hstack_separator_in_levels_scroll)
        .blendMode(design.blend_mode_hstack_separator_in_levels_scroll)
        .cornerRadius(design.corner_radius_hstack_separator_in_levels_scroll)
        .shadow(
            color: design.shadow_color_hstack_separator_in_levels_scroll,
            radius: design.shadow_radius_hstack_separator_in_levels_scroll,
            x: design.shadow_x_offset_hstack_separator_in_levels_scroll,
            y: design.shadow_y_offset_hstack_separator_in_levels_scroll
        )
        .overlay(
            RoundedRectangle(cornerRadius: design.corner_radius_hstack_separator_in_levels_scroll)
                .stroke(
                    design.stroke_color_hstack_separator_in_levels_scroll,
                    lineWidth: design.stroke_width_hstack_separator_in_levels_scroll
                )
        )
        .padding(.horizontal, design.padding_horizontal_hstack_separator_in_levels_scroll)
        .padding(.vertical, design.padding_vertical_hstack_separator_in_levels_scroll)
        .offset(
            x: design.offset_x_hstack_separator_in_levels_scroll,
            y: design.offset_y_hstack_separator_in_levels_scroll
        )
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ThemeSeparatorKey.self,
                                value: [ThemeSeparator(index: themeIndex,
                                                       y: proxy.frame(in: .named("scrollSpace")).midY)])
            }
        )
    }

    private var navigationDestinationView: some View {
        Group {
            if let themeIndex = vm.selectedThemeIndex, let level = vm.selectedLevel {
                let themeTitle = vm.themes[themeIndex].title
                let cards = vm.getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: true)
                FlashCardView(
                    collection: CardCollection(context: viewContext),
                    optionalCards: cards,
                    themeTitle: themeTitle,
                    level: level,
                    onLevelCompleted: {
                        vm.checkLevelCompletion(themeIndex: themeIndex, level: level)
                    }
                )
                .navigationBarBackButtonHidden(true)
                .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // MARK: - Helpers (UI)
    private func pill<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, design.padding_horizontal_hstack_pill_stat_in_top_bar)
            .padding(.vertical, design.padding_vertical_hstack_pill_stat_in_top_bar)
            .background(design.color_background_hstack_pill_stat_in_top_bar)
            .opacity(design.opacity_hstack_pill_stat_in_top_bar)
            .blendMode(design.blend_mode_hstack_pill_stat_in_top_bar)
            .cornerRadius(design.corner_radius_hstack_pill_stat_in_top_bar)
            .shadow(
                color: design.shadow_color_hstack_pill_stat_in_top_bar,
                radius: design.shadow_radius_hstack_pill_stat_in_top_bar,
                x: design.shadow_x_offset_hstack_pill_stat_in_top_bar,
                y: design.shadow_y_offset_hstack_pill_stat_in_top_bar
            )
            .overlay(
                RoundedRectangle(cornerRadius: design.corner_radius_hstack_pill_stat_in_top_bar)
                    .stroke(
                        design.stroke_color_hstack_pill_stat_in_top_bar,
                        lineWidth: design.stroke_width_hstack_pill_stat_in_top_bar
                    )
            )
    }

    private func pillStat(icon: String, value: Int) -> some View {
        pill {
            HStack(spacing: design.spacing_hstack_pill_stat_in_top_bar) {
                Image(systemName: icon)
                    .font(.system(size: design.font_size_icon_in_pill_stat))
                    .fontWeight(design.font_weight_icon_in_pill_stat)
                    .foregroundColor(
                        icon == "flame.fill" ? design.color_foreground_flame_icon_in_pill_stat :
                        icon == "bolt.fill" ? design.color_foreground_bolt_icon_in_pill_stat :
                        design.color_foreground_rectangle_icon_in_pill_stat
                    )
                    .opacity(design.opacity_icon_in_pill_stat)
                    .blendMode(design.blend_mode_icon_in_pill_stat)
                    .cornerRadius(design.corner_radius_icon_in_pill_stat)
                    .shadow(
                        color: design.shadow_color_icon_in_pill_stat,
                        radius: design.shadow_radius_icon_in_pill_stat,
                        x: design.shadow_x_offset_icon_in_pill_stat,
                        y: design.shadow_y_offset_icon_in_pill_stat
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_icon_in_pill_stat)
                            .stroke(
                                design.stroke_color_icon_in_pill_stat,
                                lineWidth: design.stroke_width_icon_in_pill_stat
                            )
                    )
                    .offset(
                        x: design.offset_x_icon_in_pill_stat,
                        y: design.offset_y_icon_in_pill_stat
                    )
                Text("\(value)")
                    .font(.system(size: design.font_size_value_text_in_pill_stat))
                    .fontWeight(design.font_weight_value_text_in_pill_stat)
                    .lineSpacing(design.line_spacing_value_text_in_pill_stat)
                    .foregroundColor(design.color_foreground_value_text_in_pill_stat)
                    .opacity(design.opacity_value_text_in_pill_stat)
                    .blendMode(design.blend_mode_value_text_in_pill_stat)
                    .cornerRadius(design.corner_radius_value_text_in_pill_stat)
                    .shadow(
                        color: design.shadow_color_value_text_in_pill_stat,
                        radius: design.shadow_radius_value_text_in_pill_stat,
                        x: design.shadow_x_offset_value_text_in_pill_stat,
                        y: design.shadow_y_offset_value_text_in_pill_stat
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_value_text_in_pill_stat)
                            .stroke(
                                design.stroke_color_value_text_in_pill_stat,
                                lineWidth: design.stroke_width_value_text_in_pill_stat
                            )
                    )
                    .padding(.top, design.padding_top_value_text_in_pill_stat)
                    .padding(.bottom, design.padding_bottom_value_text_in_pill_stat)
                    .padding(.leading, design.padding_leading_value_text_in_pill_stat)
                    .padding(.trailing, design.padding_trailing_value_text_in_pill_stat)
                    .offset(
                        x: design.offset_x_value_text_in_pill_stat,
                        y: design.offset_y_value_text_in_pill_stat
                    )
            }
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // MARK: - Змейка уровней
    private func snakeLevels(for theme: Theme, themeIndex: Int) -> some View {
        VStack(spacing: 22) {
            ForEach(1...11, id: \.self) { level in
                LevelButton(theme: theme, themeIndex: themeIndex, level: level, vm: vm)
                    .offset(x: xOffset(for: level))
                    .animation(.easeOut(duration: 0.2), value: vm.isLevelCompleted(themeIndex: themeIndex, level: level))
            }
        }
    }

    private func xOffset(for level: Int) -> CGFloat {
        let amplitude: CGFloat = 68
        let w = Double.pi / 3.6
        return CGFloat(sin(Double(level) * w)) * amplitude
    }

    // MARK: - Активная тема
    private func recomputeActiveTheme() {
        guard !vm.themes.isEmpty else { return }
        let candidates = separatorYs.filter { $0.value > themeCardAnchorY }.map { $0.key }
        let nextIndex = candidates.min() ?? (vm.themes.count - 1)
        vm.updateCurrentThemeIndex(nextIndex)
    }
}

// MARK: - LevelButton
struct LevelButton: View {
    let theme: Theme
    let themeIndex: Int
    let level: Int
    @ObservedObject var vm: HomeVM
    @ObservedObject private var design = DesignVM()

    private var isUnlocked: Bool { vm.isLevelUnlocked(themeIndex: themeIndex, level: level) }
    private var isCompleted: Bool { vm.isLevelCompleted(themeIndex: themeIndex, level: level) }
    private var isCurrent: Bool { isUnlocked && !isCompleted }
    private var progress: Double { min(1.0, vm.progressForLevel(themeIndex: themeIndex, level: level)) }
    private var icon: String {
        let set = ["heart.fill", "airplane", "star.fill", "bolt.fill", "book.fill"]
        return set[(level - 1) % set.count]
    }

    var body: some View {
        Button {
            if isUnlocked {
                let cards = vm.getCardsForLevel(themeIndex: themeIndex, level: level, createIfMissing: true)
                if !cards.isEmpty {
                    vm.selectedThemeIndex = themeIndex
                    vm.selectedLevel = level
                    vm.navigateToFlashCard = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            } else {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        } label: {
            ZStack {
                // Background circle for progress (current level)
                if isCurrent {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            design.color_stroke_progress_circle_in_level_button,
                            style: StrokeStyle(
                                lineWidth: design.stroke_width_progress_circle_in_level_button,
                                lineCap: .round
                            )
                        )
                        .frame(width: 64 + design.stroke_width_progress_circle_in_level_button * 2, height: 64 + design.stroke_width_progress_circle_in_level_button * 2)
                        .opacity(design.opacity_progress_circle_in_level_button)
                        .blendMode(design.blend_mode_progress_circle_in_level_button)
                        .shadow(
                            color: design.shadow_color_progress_circle_in_level_button,
                            radius: design.shadow_radius_progress_circle_in_level_button,
                            x: design.shadow_x_offset_progress_circle_in_level_button,
                            y: design.shadow_y_offset_progress_circle_in_level_button
                        )
                        .rotationEffect(.degrees(-90))
                        .onChange(of: progress) { newValue in
                            if newValue >= 1.0 {
                                vm.markLevelCompleted(themeIndex: themeIndex, level: level)
                            }
                        }
                } else if isCompleted {
                    Circle()
                        .stroke(
                            design.color_stroke_completed_circle_in_level_button,
                            lineWidth: design.stroke_width_completed_circle_in_level_button
                        )
                        .frame(width: 64 + design.stroke_width_completed_circle_in_level_button * 2, height: 64 + design.stroke_width_completed_circle_in_level_button * 2)
                        .opacity(design.opacity_completed_circle_in_level_button)
                        .blendMode(design.blend_mode_completed_circle_in_level_button)
                        .shadow(
                            color: design.shadow_color_completed_circle_in_level_button,
                            radius: design.shadow_radius_completed_circle_in_level_button,
                            x: design.shadow_x_offset_completed_circle_in_level_button,
                            y: design.shadow_y_offset_completed_circle_in_level_button
                        )
                }

                // Main circle
                Circle()
                    .fill(circleFill(isCompleted: isCompleted))
                    .frame(width: 64, height: 64)
                    .opacity(design.opacity_main_circle_in_level_button)
                    .blendMode(design.blend_mode_main_circle_in_level_button)
                    .cornerRadius(design.corner_radius_main_circle_in_level_button)
                    .shadow(
                        color: design.shadow_color_main_circle_in_level_button,
                        radius: design.shadow_radius_main_circle_in_level_button,
                        x: design.shadow_x_offset_main_circle_in_level_button,
                        y: design.shadow_y_offset_main_circle_in_level_button
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                design.stroke_color_main_circle_in_level_button.opacity(isCompleted ? 0.35 : 0.15),
                                lineWidth: design.stroke_width_main_circle_in_level_button
                            )
                    )

                // Icon
                Image(systemName: icon)
                    .font(.system(size: design.font_size_icon_in_level_button))
                    .fontWeight(design.font_weight_icon_in_level_button)
                    .foregroundColor(
                        isUnlocked
                            ? (isCompleted
                                ? design.color_foreground_completed_icon_in_level_button
                                : design.color_foreground_uncompleted_icon_in_level_button)
                            : design.color_foreground_locked_icon_in_level_button
                    )
                    .opacity(design.opacity_icon_in_level_button)
                    .blendMode(design.blend_mode_icon_in_level_button)
                    .cornerRadius(design.corner_radius_icon_in_level_button)
                    .shadow(
                        color: design.shadow_color_icon_in_level_button,
                        radius: design.shadow_radius_icon_in_level_button,
                        x: design.shadow_x_offset_icon_in_level_button,
                        y: design.shadow_y_offset_icon_in_level_button
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: design.corner_radius_icon_in_level_button)
                            .stroke(
                                design.stroke_color_icon_in_level_button,
                                lineWidth: design.stroke_width_icon_in_level_button
                            )
                    )
            }
            .padding(design.stroke_width_progress_circle_in_level_button) // Add padding to prevent clipping
            .background(design.color_background_level_button)
            .opacity(design.opacity_level_button)
            .blendMode(design.blend_mode_level_button)
            .cornerRadius(design.corner_radius_level_button)
            .shadow(
                color: design.shadow_color_level_button,
                radius: design.shadow_radius_level_button,
                x: design.shadow_x_offset_level_button,
                y: design.shadow_y_offset_level_button
            )
            .overlay(
                RoundedRectangle(cornerRadius: design.corner_radius_level_button)
                    .stroke(
                        design.stroke_color_level_button,
                        lineWidth: design.stroke_width_level_button
                    )
            )
        }
        .disabled(!isUnlocked)
    }

    private func circleFill(isCompleted: Bool) -> LinearGradient {
        if isCompleted {
            return design.color_fill_completed_main_circle_in_level_button
        } else {
            return design.color_fill_uncompleted_main_circle_in_level_button
        }
    }
}
// MARK: - Preferences
private struct ThemeSeparator: Equatable, Hashable {
    let index: Int
    let y: CGFloat
}

private struct ThemeSeparatorKey: PreferenceKey {
    static var defaultValue: [ThemeSeparator] = []
    static func reduce(value: inout [ThemeSeparator], nextValue: () -> [ThemeSeparator]) {
        value.append(contentsOf: nextValue())
    }
}

private struct ThemeCardAnchorKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Превью
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(context: PersistenceController.preview.container.viewContext)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
