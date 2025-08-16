//
//  ScreenTwo.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics
import CoreData

// Второй экран онбординга
struct SecondScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: User.entity(), sortDescriptors: []) private var users: FetchedResults<User>
    
    @Binding var currentPage: Int
    @ObservedObject var vm: OnboardingVM
    @State private var startTime: Date?
    
    // Жёстко заданный список языков
    private let staticLanguages = [
        "English",     // ~1.5 млрд носителей и изучающих
        "Chinese",     // ~1.1 млрд (в основном мандарин)
        "Spanish",     // ~600 млн
        "Arabic",      // ~370 млн (все диалекты)
        "French",      // ~300 млн
        "Russian",     // ~260 млн
        "Portuguese",  // ~260 млн
        "German",      // ~130 млн
        "Japanese",    // ~125 млн
        "Italian"      // ~70 млн
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            TitleView(vm: vm)
            LanguageSelectionView(
                languages: staticLanguages,
                currentPage: $currentPage,
                viewContext: viewContext,
                user: users.first
            )
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
    let languages: [String]
    @State var selectedLanguage = ""
    @Binding var currentPage: Int
    let viewContext: NSManagedObjectContext
    let user: User?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                ForEach(languages.indices, id: \.self) { index in
                    let lang = languages[index]
                    Button(action: {
                        selectedLanguage = lang
                        
                        Analytics.logEvent("language_selected", parameters: [
                            "language": lang
                        ])
                        
                        // Сохраняем в Core Data
                        if let user = user {
                            user.onboarding_select_language = lang
                            do {
                                try viewContext.save()
                                print("✅ Language saved to CoreData: \(lang)")
                            } catch {
                                print("❌ Failed to save language: \(error.localizedDescription)")
                            }
                        } else {
                            print("❌ No user found to update language")
                        }

                        withAnimation {
                            currentPage += 1
                        }

                        Analytics.logEvent("second_screen_next_page", parameters: [
                            "new_page": currentPage
                        ])

                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        LanguageItemView(
                            language: lang,
                            isSelected: selectedLanguage == lang,
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
    let language: String
    let isSelected: Bool
    let showDivider: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(uiImage: flagImage(for: language))
                    .resizable()
                    .frame(width: 30, height: 20)
                Text(language)
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
        default: return UIImage()
        }
    }
}

