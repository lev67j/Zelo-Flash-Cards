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
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: User.entity(), sortDescriptors: []) private var users: FetchedResults<User>

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
                StudyTimeButton(timeInMinutes: 10, label: "Relaxed", emoji: "😊")
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 15, label: "Relaxed but effective", emoji: "🙂")
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 20, label: "Accelerated", emoji: "🎓")
                Divider().background(Color(hex: "#546a50").opacity(0.5)).padding(.horizontal)
                
                StudyTimeButton(timeInMinutes: 30, label: "Super accelerated", emoji: "🚀")
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
    }

    // MARK: - StudyTimeButton as inner view with logic
    private func StudyTimeButton(timeInMinutes: Int, label: String, emoji: String) -> some View {
        Button(action: {
           Analytics.logEvent("study_time_selected", parameters: [
                "time_minutes": timeInMinutes
            ])
            
            // Сохраняем в CoreData
            if let user = users.first {
                user.time_study_per_day = Int64(timeInMinutes * 60) // секунды
                do {
                    try viewContext.save()
                    print("✅ Study time saved to CoreData: \(timeInMinutes) minutes")
                } catch {
                    print("❌ Failed to save study time: \(error.localizedDescription)")
                }
            } else {
                print("❌ No user found to save study time")
            }

            withAnimation {
                currentPage += 1
            }

            Analytics.logEvent("fourth_screen_next_page", parameters: [
                "new_page": currentPage
            ])
            
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
