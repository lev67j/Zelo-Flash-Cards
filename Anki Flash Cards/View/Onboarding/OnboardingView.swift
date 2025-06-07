//
//  OnboardingView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData



// for last screen:
//.onAppear {
//    UserDefaults.standard.set(true, forKey: "isOnboardingCompleted")
//}

// Основное представление онбординга
struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ShopLanguages.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ShopLanguages.name_language, ascending: true)]
    ) var languages: FetchedResults<ShopLanguages>
    
    @State private var currentPage = 0
    @State private var selectedLanguage: ShopLanguages? = nil
    @State private var selectedStudyTime: Int? = nil
    @State private var selectedAgeRange: String? = nil
    
    private let isOnboardingCompletedKey = "isOnboardingCompleted"
    
    var body: some View {
        if !UserDefaults.standard.bool(forKey: isOnboardingCompletedKey) {
            VStack {
                HeaderView(currentPage: $currentPage)
                SwitchView(currentPage: $currentPage, selectedLanguage: $selectedLanguage, selectedStudyTime: $selectedStudyTime, selectedAgeRange: $selectedAgeRange, languages: languages)
                Spacer()
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .onAppear {
                InitialDataSetup.setupInitialData(context: viewContext)
                print("Языки загружены: \(languages.count)")
                for language in languages {
                    print("Язык: \(language.name_language ?? ""), Коллекции: \(language.language_collections?.count ?? 0)")
                }
            }
        } else {
            ContentView() // Переход на основное представление после онбординга
        }
    }
}

// Основное содержимое онбординга
struct SwitchView: View {
    @Binding var currentPage: Int
    @Binding var selectedLanguage: ShopLanguages?
    @Binding var selectedStudyTime: Int?
    @Binding var selectedAgeRange: String?
    let languages: FetchedResults<ShopLanguages>
    
    var body: some View {
        if currentPage == 0 {
            FirstScreen(currentPage: $currentPage)
        } else if currentPage == 1 {
            SecondScreen(currentPage: $currentPage, selectedLanguage: $selectedLanguage, languages: languages)
        } else if currentPage == 2 {
            ThirdScreen(currentPage: $currentPage)
        } else if currentPage == 3 {
            FourthScreen(currentPage: $currentPage, selectedStudyTime: $selectedStudyTime)
        } else if currentPage == 4 {
            FifthScreen(currentPage: $currentPage, selectedAgeRange: $selectedAgeRange)
        } else if currentPage == 5 {
            SixthScreen(currentPage: $currentPage)
        } else if currentPage == 6 {
            SeventhScreen(currentPage: $currentPage)
        }else if currentPage == 7 {
            EighthScreen(currentPage: $currentPage)
        }else if currentPage == 8 {
            //NineScreen(currentPage: $currentPage)
        }else if currentPage == 9 {
            //TenScreen(currentPage: $currentPage)
        }else if currentPage == 10 {
            //ElevenScreen(currentPage: $currentPage)
        }else if currentPage == 11 {
            SeventhScreen(currentPage: $currentPage)
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
            ProgressView(value: Float(currentPage + 1), total: 11)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 5)
            Spacer()
        }
        .padding()
    }
}
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
