//
//  OnboardingView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

// Основное представление онбординга
struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ShopLanguages.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ShopLanguages.name_language, ascending: true)]
    ) var languages: FetchedResults<ShopLanguages>
    
    @State private var currentPage = 0 {
        didSet {
            Analytics.logEvent("onboarding_page_changed", parameters: [
                "current_page": currentPage
            ])
        }
    }
    
    @State private var startTime: Date?
    
    private let isOnboardingCompletedKey = "isOnboardingCompleted"
    @AppStorage("isOnboardingCompletedKey") private var isOnboardingCompleted = false
    
    @ObservedObject private var vm = OnboardingVM()
    
    @StateObject private var stateProperties = StatePropertiesVM()
    
    var body: some View {
        if !isOnboardingCompleted {
            VStack {
                HeaderView(currentPage: $currentPage)
                SwitchView(currentPage: $currentPage,
                           languages: languages,
                           vm: vm
                )
            }
            .background(
                Color(hex: "#ddead1")
                    .ignoresSafeArea())
            .onAppear {
                startTime = Date()
                Analytics.logEvent("onboarding_screen_appear", parameters: nil)
                
                InitialDataSetup.setupInitialData(context: viewContext)
                
                Analytics.logEvent("onboarding_languages_loaded", parameters: [
                    "languages_count": languages.count
                ])
                
                print("Language downloaded: \(languages.count)")
                for language in languages {
                    print("Language: \(language.name_language ?? ""), Collections: \(language.language_collections?.count ?? 0), Priority: \(language.priority)")
                }
            }
            .onDisappear {
                if let start = startTime {
                    let duration = Date().timeIntervalSince(start)
                    Analytics.logEvent("onboarding_time_spent", parameters: [
                        "duration_seconds": duration
                    ])
                }
                Analytics.logEvent("onboarding_screen_disappear", parameters: nil)
            }
        } else {
            // Переход на основное представление после онбординга
            TabBarElements()
                .environmentObject(stateProperties)
        }
    }
}

// Основное содержимое онбординга
struct SwitchView: View {
    @Binding var currentPage: Int
    let languages: FetchedResults<ShopLanguages>
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack {
            // current onboarding screen
            VStack {
                if currentPage == 0 {
                    FirstScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 1 {
                    SecondScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 2 {
                    ThirdScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 3 {
                    FourthScreen(currentPage: $currentPage, vm: vm)
                } else if currentPage == 4 {
                    FifthScreen(currentPage: $currentPage, vm: vm)
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
                                Analytics.logEvent("onboarding_back_button_tapped", parameters: [
                                    "new_page": currentPage
                                ])
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

