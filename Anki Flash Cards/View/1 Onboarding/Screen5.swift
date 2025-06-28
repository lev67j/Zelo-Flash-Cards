//
//  ScreenFifth.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import CoreData

// Пятый экран - выбор возраста
struct FifthScreen: View {
    @Binding var currentPage: Int
    @Binding var selectedAgeRange: String?
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How old are you?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding(.top)
            
            VStack(spacing: 10) {
                AgeButton(ageRange: "From 13 to 17 years old", color: Color(red: 1.0, green: 0.8, blue: 0.8), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "18 to 24 years old", color: Color(red: 1.0, green: 0.9, blue: 0.7), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "25 to 34 years old", color: Color(red: 1.0, green: 0.9, blue: 0.6), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "35 to 44 years old", color: Color(red: 1.0, green: 0.9, blue: 0.6), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "45 to 54 years old", color: Color(red: 0.8, green: 1.0, blue: 0.8), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "55 to 64 years old", color: Color(red: 0.7, green: 1.0, blue: 0.9), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                AgeButton(ageRange: "65+ years old", color: Color(red: 0.7, green: 0.9, blue: 1.0), selectedAgeRange: $selectedAgeRange, currentPage: $currentPage)
            }
            .padding(.horizontal)
            .background(Color(hex: "#546a50").opacity(0.3))
            .cornerRadius(20)
            .padding()
            
            Spacer()
        }
        .onChange(of: selectedAgeRange) {
            saveAge()
        }
    }
    
    private func saveAge() {
        if let ageRange = selectedAgeRange {
            let user = User(context: viewContext)
            // Примерное преобразование возрастного диапазона в среднее значение (в годах)
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
            withAnimation {
                currentPage += 1
            }
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
