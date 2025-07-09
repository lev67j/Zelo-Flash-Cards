//
//  ScreenFourth.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import SwiftUI
import FirebaseAnalytics

// Четвертый экран - выбор времени изучения
struct FourthScreen: View {
    @Binding var currentPage: Int
    @Binding var selectedStudyTime: Int?
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vm: OnboardingVM
    
    @State private var startTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How much time do you want to study per day?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding()
            
            VStack(spacing: 10) {
                StudyTimeButton(timeInMinutes: 10, label: "Relaxed", emoji: "😊", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 15, label: "Relaxed but effective", emoji: "🙂", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 20, label: "Accelerated", emoji: "🎓", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 30, label: "Super accelerated", emoji: "🚀", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
            }
            .padding(.horizontal)
            .background(Color(hex: "#546a50").opacity(0.3))
            .cornerRadius(20)
            .padding()
            
            Spacer()
        }
        .onAppear {
            startTime = Date()
            Analytics.logEvent("fourth_screen_appear", parameters: nil)
        }
        .onDisappear {
            Analytics.logEvent("fourth_screen_disappear", parameters: nil)
            if let start = startTime {
                let duration = Date().timeIntervalSince(start)
                Analytics.logEvent("fourth_screen_time_spent", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
        .onChange(of: selectedStudyTime) {
            saveStudyTime()
        }
    }
    
    private func saveStudyTime() {
        if let time = selectedStudyTime {
            let user = User(context: viewContext)
            user.time_study_per_day = Int64(time * 60) // Конвертация минут в секунды
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при сохранении времени изучения: \(error)")
            }
        }
    }
}

private struct StudyTimeButton: View {
    let timeInMinutes: Int
    let label: String
    let emoji: String
    @Binding var selectedStudyTime: Int?
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            selectedStudyTime = timeInMinutes
            
            // Логируем выбранное время
            Analytics.logEvent("study_time_selected", parameters: [
                "time_minutes": timeInMinutes
            ])
            
            withAnimation {
                currentPage += 1
            }
            
            // Логируем переход
            Analytics.logEvent("fourth_screen_next_page", parameters: [
                "new_page": currentPage
            ])
            
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        }) {
            HStack {
                HStack {
                    Text(emoji)
                        .font(.title)
                    
                    VStack(alignment: .leading) {
                        Text("\(timeInMinutes) minutes")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(label)
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                    
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}

/*
// Четвертый экран - выбор времени изучения
struct FourthScreen: View {
    @Binding var currentPage: Int
    @Binding var selectedStudyTime: Int?
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vm: OnboardingVM
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How much time do you want to study per day?")
                .font(.system(size: vm.caption_font_size))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#546a50"))
                .padding()
            
            VStack(spacing: 10) {
                StudyTimeButton(timeInMinutes: 10, label: "Relaxed", emoji: "😊", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 15, label: "Relaxed but effective", emoji: "🙂", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 20, label: "Accelerated", emoji: "🎓", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
                Divider()
                    .background(Color(hex: "#546a50").opacity(0.5))
                    .padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 30, label: "Super accelerated", emoji: "🚀", selectedStudyTime: $selectedStudyTime, currentPage: $currentPage)
            }
            .padding(.horizontal)
            .background(Color(hex: "#546a50").opacity(0.3))
            .cornerRadius(20)
            .padding()
            
            Spacer()
        }
        .onChange(of: selectedStudyTime) {
            saveStudyTime()
        }
    }
    
    private func saveStudyTime() {
        if let time = selectedStudyTime {
            let user = User(context: viewContext)
            user.time_study_per_day = Int64(time * 60) // Конвертация минут в секунды
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при сохранении времени изучения: \(error)")
            }
        }
    }
}

private struct StudyTimeButton: View {
    let timeInMinutes: Int
    let label: String
    let emoji: String
    @Binding var selectedStudyTime: Int?
    @Binding var currentPage: Int
    
    var body: some View {
        Button(action: {
            selectedStudyTime = timeInMinutes
            withAnimation {
                currentPage += 1
            }
            
            // Вибрация
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
      
        }) {
            HStack {
                HStack {
                    Text(emoji)
                        .font(.title)
                    
                    VStack(alignment: .leading) {
                        Text("\(timeInMinutes) minutes")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(label)
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                    
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
            }
            .padding()
        }
    }
}
*/
