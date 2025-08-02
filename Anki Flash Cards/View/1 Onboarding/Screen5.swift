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
    @Binding var selectedAgeRange: String?
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How old are you?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding(.top)
            
            VStack(spacing: 10) {
                AgeButton(ageRange: "From 13 to 17 years old", color: Color(red: 1.0, green: 0.8, blue: 0.8), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "18 to 24 years old", color: Color(red: 1.0, green: 0.9, blue: 0.7), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "25 to 34 years old", color: Color(red: 1.0, green: 0.9, blue: 0.6), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "35 to 44 years old", color: Color(red: 1.0, green: 0.9, blue: 0.6), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "45 to 54 years old", color: Color(red: 0.8, green: 1.0, blue: 0.8), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "55 to 64 years old", color: Color(red: 0.7, green: 1.0, blue: 0.9), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                AgeButton(ageRange: "65+ years old", color: Color(red: 0.7, green: 0.9, blue: 1.0), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
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
        .onChange(of: selectedAgeRange) {
            saveAge()
        }
    }
    
    private func saveAge() {
        if let ageRange = selectedAgeRange {
            let user = User(context: viewContext)
            let ageValue: Int64 = {
                switch ageRange {
                case "From 13 to 17 years old": return 15
                case "18 to 24 years old": return 21
                case "25 to 34 years old": return 29
                case "35 to 44 years old": return 39
                case "45 to 54 years old": return 49
                case "55 to 64 years old": return 59
                case "65+ years old": return 65
                default: return 0
                }
            }()
            user.age = ageValue
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при сохранении возраста: \(error)")
            }
        }
    }
}

private struct AgeButton: View {
    let ageRange: String
    let color: Color
    @Binding var selectedAgeRange: String?
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            selectedAgeRange = ageRange
            
            // Логируем выбранный возраст
            Analytics.logEvent("age_range_selected", parameters: [
                "age_range": ageRange
            ])
            
            withAnimation {
                currentPage += 1
            }
            
            // Логируем переход
            Analytics.logEvent("fifth_screen_next_page", parameters: [
                "new_page": currentPage
            ])
            
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        }) {
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
