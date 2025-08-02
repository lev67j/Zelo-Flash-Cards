//
//  ScreenTwo.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Второй экран онбординга
struct SecondScreen: View {
    @Binding var currentPage: Int
    @Binding var selectedLanguage: ShopLanguages?
    let languages: FetchedResults<ShopLanguages>
    
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            TitleView(vm: vm)
            LanguageSelectionView(languages: languages, selectedLanguage: $selectedLanguage, currentPage: $currentPage)
        }
        .padding(.horizontal)
        .onAppear {
            startTime = Date()
            Analytics.logEvent("second_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("second_screen_disappear", parameters: nil)
            
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("second_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
}

// Подкомпонент для заголовка
private struct TitleView: View {
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Which language do you want to learn?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding()
        }
    }
}

// Подкомпонент для выбора языка
private struct LanguageSelectionView: View {
    let languages: FetchedResults<ShopLanguages>
    @Binding var selectedLanguage: ShopLanguages?
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                ForEach(languages.indices, id: \.self) { index in
                    Button(action: {
                        selectedLanguage = languages[index]
                        
                        // Логируем выбор языка
                        Analytics.logEvent("language_selected", parameters: [
                            "language": languages[index].name_language ?? "unknown"
                        ])
                        
                        withAnimation {
                            currentPage += 1
                        }
                        
                        // Логируем переход
                        Analytics.logEvent("second_screen_next_page", parameters: [
                            "new_page": currentPage
                        ])
                        
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                    }) {
                        LanguageItemView(
                            language: languages[index],
                            isSelected: selectedLanguage == languages[index],
                            showDivider: index < languages.count - 1
                        )
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding(.bottom)
    }
}

// Подкомпонент для элемента языка
private struct LanguageItemView: View {
    let language: ShopLanguages
    let isSelected: Bool
    let showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(uiImage: flagImage(for: language.name_language ?? ""))
                    .resizable()
                    .frame(width: 30, height: 20)
                Text(language.name_language ?? "")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(hex: "#546a50") : Color.clear)
            
            if showDivider {
                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal)
            }
        }
    }
    
    private func flagImage(for language: String) -> UIImage {
        switch language.lowercased() {
        case "english": return UIImage(named: "flag_uk") ?? UIImage()
        case "spanish": return UIImage(named: "flag_spain") ?? UIImage()
        case "japanese": return UIImage(named: "flag_japan") ?? UIImage()
        case "french": return UIImage(named: "flag_france") ?? UIImage()
        case "portuguese": return UIImage(named: "flag_portugal") ?? UIImage()
        case "german": return UIImage(named: "flag_germany") ?? UIImage()
        case "italian": return UIImage(named: "flag_italy") ?? UIImage()
        case "korean": return UIImage(named: "flag_southkorea") ?? UIImage()
        case "russian": return UIImage(named: "flag_russia") ?? UIImage()
        default: return UIImage()
        }
    }
}

