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
                design.color_back_home_view.ignoresSafeArea()
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
        VStack(spacing: 0) {
            topBar
            languageScroll
            divider
            themeCard
            levelsScroll
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            languageButton
            pillStat(icon: "flame.fill", value: vm.currentStreak)
            pillStat(icon: "rectangle.on.rectangle.fill", value: vm.studiedCardsCount)
            pillStat(icon: "bolt.fill", value: vm.starsCount)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
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
                    .font(.system(size: 18))
            }
        }
    }

    private var languageScroll: some View {
        Group {
            if showLanguageScroll {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(vm.availableLanguages) { language in
                            Button {
                                vm.switchLanguage(to: language.name)
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    showLanguageScroll = false
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(language.flag).font(.system(size: 22))
                                    Text(language.name)
                                        .font(.headline)
                                        .foregroundColor(vm.selectedLanguage == language.name ? .white : .gray)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(vm.selectedLanguage == language.name ? Color.blue : Color.gray.opacity(0.2))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 70)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(design.color_line_cell_set_home.opacity(0.9))
            .padding(.bottom, 15)
    }
  
    private var themeCard: some View {
        Group {
            if let currentTheme = vm.currentTheme {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Words \(currentTheme.cards.count)") // \(currentTheme.cards.count)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text(currentTheme.title)
                        .font(.system(size: 22, weight: .bold))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#FBDA4B"))
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
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
            LazyVStack(spacing: 30) {
                ForEach(vm.themes.indices, id: \.self) { themeIndex in
                    let theme = vm.themes[themeIndex]
                    snakeLevels(for: theme, themeIndex: themeIndex)
                    separator(themeIndex: themeIndex)
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 70)
            .onAppear {
                Analytics.logEvent("ai_quest_scrollview_appear", parameters: nil)
            }
        }
        .coordinateSpace(name: "scrollSpace")
    }

    private func separator(themeIndex: Int) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(design.color_line_cell_set_home).frame(height: 1)
            Image(systemName: vm.isThemeUnlocked(themeIndex: themeIndex) ? "lock.open.fill" : "lock.fill")
                .resizable().scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundColor(.gray)
            Rectangle().fill(design.color_line_cell_set_home).frame(height: 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
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
                        // after finishing session we re-check completion; if everything good - mark and update UI
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
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
            .cornerRadius(12)
    }

    private func pillStat(icon: String, value: Int) -> some View {
        pill {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(icon == "flame.fill" ? .orange : icon == "bolt.fill" ? .yellow : .gray.opacity(0.4))
                Text("\(value)")
                    .font(.system(size: 18, weight: .medium))
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
                if isCurrent {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.blue.opacity(0.8), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 74, height: 74)
                        .rotationEffect(.degrees(-90))
                        .onChange(of: progress) { newValue in
                            // if fully filled -> mark completed instantly (safety: only once)
                            if newValue >= 1.0 {
                                vm.markLevelCompleted(themeIndex: themeIndex, level: level)
                            }
                        }
                } else if isCompleted {
                    Circle()
                        .stroke(Color(hex: "#FBDA4B"), lineWidth: 5)
                        .frame(width: 74, height: 74)
                }
                Circle()
                    .fill(circleFill(isCompleted: isCompleted))
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(isCompleted ? 0.35 : 0.15), lineWidth: 2)
                    )
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(isCompleted ? .white : .white.opacity(0.9))
                    .opacity(isUnlocked ? 1.0 : 0.45)
            }
        }
        .disabled(!isUnlocked)
    }
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
    private func circleFill(isCompleted: Bool) -> LinearGradient {
        if isCompleted {
            return LinearGradient(colors: [Color(hex: "#FBDA4B"), Color(hex: "#FBDA4B")], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.45)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
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
