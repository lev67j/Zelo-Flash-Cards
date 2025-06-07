//
//  OnboardingView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Основное представление онбординга
struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ShopLanguages.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ShopLanguages.name_language, ascending: true)]
    ) var languages: FetchedResults<ShopLanguages>
    
    @State private var currentPage = 0
    @State private var selectedLanguage: ShopLanguages? = nil
    
    private let isOnboardingCompletedKey = "isOnboardingCompleted"
    
    var body: some View {
        if !UserDefaults.standard.bool(forKey: isOnboardingCompletedKey) {
            VStack {
                HeaderView(currentPage: $currentPage)
                SwitchView(currentPage: $currentPage, selectedLanguage: $selectedLanguage, languages: languages)
                Spacer()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
        } else {
            ContentView() // Переход на основное представление после онбординга
        }
    }
}

// Представление заголовка с прогресс-баром и кнопкой назад
struct HeaderView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            if currentPage > 0 {
                Button(action: {
                    withAnimation {
                        currentPage -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .padding()
                }
            } else {
                Spacer()
                    .frame(width: 40)
            }
            ProgressView(value: Float(currentPage + 1), total: 2)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 5)
            Spacer()
        }
        .padding()
    }
}

// Основное содержимое онбординга
struct SwitchView: View {
    @Binding var currentPage: Int
    @Binding var selectedLanguage: ShopLanguages?
    let languages: FetchedResults<ShopLanguages>
    
    var body: some View {
        if currentPage == 0 {
            FirstScreen(currentPage: $currentPage)
        } else if currentPage == 1 {
            SecondScreen(currentPage: $currentPage, selectedLanguage: $selectedLanguage, languages: languages)
        } else if currentPage == 2 {
            ContentView() // Переход на основное представление после онбординга
                .transition(.opacity)
        }
    }
}

// Первый экран онбординга
struct FirstScreen: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Image("onboardingImage1")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text("Anki Flashcards")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Remember More, Forget Less.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Get started")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
}

// Второй экран онбординга
struct SecondScreen: View {
    @Binding var currentPage: Int
    @Binding var selectedLanguage: ShopLanguages?
    let languages: FetchedResults<ShopLanguages>
    
    var body: some View {
        VStack(spacing: 20) {
            TitleView()
            LanguageSelectionView(languages: languages, selectedLanguage: $selectedLanguage)
            NextButtonView(currentPage: $currentPage, selectedLanguage: $selectedLanguage)
        }
        .padding(.horizontal)
    }
}

// Подкомпонент для заголовка
private struct TitleView: View {
    var body: some View {
        Text("Which language do you want to learn?")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.blue)
    }
}

// Подкомпонент для выбора языка
private struct LanguageSelectionView: View {
    let languages: FetchedResults<ShopLanguages>
    @Binding var selectedLanguage: ShopLanguages?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(languages, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        LanguageItemView(language: language, isSelected: selectedLanguage == language)
                    }
                }
            }
        }
    }
}

// Подкомпонент для элемента языка
private struct LanguageItemView: View {
    let language: ShopLanguages
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(uiImage: flagImage(for: language.name_language ?? ""))
                .resizable()
                .frame(width: 30, height: 20)
            Text(language.name_language ?? "")
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
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

// Подкомпонент для кнопки "Next"
private struct NextButtonView: View {
    @Binding var currentPage: Int
    @Binding var selectedLanguage: ShopLanguages?
    
    var body: some View {
        Button(action: {
            if selectedLanguage != nil {
                withAnimation {
                    currentPage += 1
                    UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
                }
            }
        }) {
            Text("Next")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedLanguage != nil ? Color.blue : Color.gray)
                .cornerRadius(10)
        }
        .disabled(selectedLanguage == nil)
    }
}

// Стиль прогресс-бара
struct LinearProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 5)
                    .foregroundColor(Color.gray.opacity(0.3))
                Rectangle()
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 5)
                    .foregroundColor(.blue)
            }
        }
    }
}

