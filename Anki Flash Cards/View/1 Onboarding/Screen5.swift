//
//  ScreenFifth.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Пятый экран - выбор возраста
struct FifthScreen: View {
    @Binding var currentPage: Int
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var vm: OnboardingVM
    @State private var startTime: Date?

    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: [],
        animation: .default
    ) private var users: FetchedResults<User>

    @State private var isButtonTapped = false
 
    var body: some View {
        VStack(spacing: 20) {
            Text("How old are you?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding(.top)
            
            VStack(spacing: 10) {
                ForEach(ageOptions, id: \.label) { option in
                    AgeButton(
                        ageRange: option.label,
                        color: option.color
                    ) {
                        // Вибрация
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                       
                        // Проверяем, был ли уже переход
                        guard !isButtonTapped else { return }
                        isButtonTapped = true
                        
                        saveAge(option.value)
                        logSelection(option.label)
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    
                    if option.label != ageOptions.last?.label {
                        Divider()
                            .background(Color(hex: "#546a50").opacity(0.5))
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.horizontal)
            .background(Color(hex: "#546a50").opacity(0.3))
            .cornerRadius(20)
            .padding()
            
            Spacer()
        }
        .onAppear {
            startTime = Date()
            Analytics.logEvent("fifth_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("fifth_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("fifth_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }

    private func saveAge(_ age: Int64) {
        guard let user = users.first else {
            print("❌ Не найден user для сохранения возраста")
            return
        }

        user.age = age
        do {
            try viewContext.save()
            print("✅ Age saved to CoreData: \(age)")
        } catch {
            print("❌ Ошибка при сохранении возраста: \(error)")
        }
    }

    private func logSelection(_ label: String) {
        Analytics.logEvent("age_range_selected", parameters: [
            "age_range": label
        ])
        Analytics.logEvent("fifth_screen_next_page", parameters: [
            "new_page": currentPage + 1
        ])
    }

    private var ageOptions: [(label: String, value: Int64, color: Color)] {
        return [
            ("From 13 to 17 years old", 15, Color(red: 1.0, green: 0.8, blue: 0.8)),
            ("18 to 24 years old", 21, Color(red: 1.0, green: 0.9, blue: 0.7)),
            ("25 to 34 years old", 29, Color(red: 1.0, green: 0.9, blue: 0.6)),
            ("35 to 44 years old", 39, Color(red: 1.0, green: 0.9, blue: 0.6)),
            ("45 to 54 years old", 49, Color(red: 0.8, green: 1.0, blue: 0.8)),
            ("55 to 64 years old", 59, Color(red: 0.7, green: 1.0, blue: 0.9)),
            ("65+ years old", 65, Color(red: 0.7, green: 0.9, blue: 1.0))
        ]
    }
}

private struct AgeButton: View {
    let ageRange: String
    let color: Color
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)
                
                Text(ageRange)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}
