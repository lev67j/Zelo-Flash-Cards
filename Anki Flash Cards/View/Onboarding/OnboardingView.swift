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
    @AppStorage("isOnboardingCompletedKey") private var isOnboardingCompleted = false
    @ObservedObject private var vm = OnboardingVM()
    
    var body: some View {
        if !isOnboardingCompleted {
            VStack {
                HeaderView(currentPage: $currentPage)
                SwitchView(currentPage: $currentPage,
                           selectedLanguage: $selectedLanguage,
                           selectedStudyTime: $selectedStudyTime,
                           selectedAgeRange: $selectedAgeRange,
                           languages: languages,
                           vm: vm
                )
            }
            .background(
                Color(hex: "#ddead1")
                .ignoresSafeArea())
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
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack {
            // current onboarding screen
            VStack {
                if currentPage == 0 {
                    FirstScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 1 {
                    SecondScreen(currentPage: $currentPage, selectedLanguage: $selectedLanguage, languages: languages, vm: vm)
                } else if currentPage == 2 {
                    ThirdScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 3 {
                    FourthScreen(currentPage: $currentPage, selectedStudyTime: $selectedStudyTime, vm: vm)
                } else if currentPage == 4 {
                    FifthScreen(currentPage: $currentPage, selectedAgeRange: $selectedAgeRange, vm: vm)
                } else if currentPage == 5 {
                    SixthScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 6 {
                    SeventhScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 7 {
                    EighthScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 8 {
                    NineScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 9 {
                    TenScreen(currentPage: $currentPage, vm: vm)
                }
            }
        }
    }
}

// Представление заголовка с прогресс-баром и кнопкой назад
struct HeaderView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack {
             if currentPage < 9 {
                HStack {
                    
                    // Back Button
                    if currentPage > 1 {
                        VStack {
                            Button {
                                withAnimation {
                                    currentPage -= 1
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color(hex: "#546a50"))
                                    .bold()
                            }
                        }
                        .padding(.trailing)
                    }
                    
                    VStack {
                        ProgressView(value: Float(currentPage + 1), total: 10)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 300, height: 5)
                    }
                }
                .padding(.top)
            }
        }
    }
}
struct LinearProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(5)
                Rectangle()
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
                    .foregroundColor(Color(hex: "#546a50"))
                    .cornerRadius(5)
            }
        }
    }
}
