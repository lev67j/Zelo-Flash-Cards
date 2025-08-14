//
//  ProfileView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import CoreData
import FirebaseAnalytics

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var studiedCardsCount = 0
    @State private var starsCount = 0
    @AppStorage("totalTimeSpent") private var totalTimeSpent: Double = 0
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    
    @State private var screenEnterTime: Date?
    @State private var lastActionTime: Date?
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                
                // User avatar and name
                VStack {
                    Button {
                        logAction(event: "profile_avatar_tap")
                    } label: {
                        Image("icon_image")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(55)
                    }

                    Button {
                        logAction(event: "profile_username_tap")
                    } label: {
                        Text("Anonymous User")
                            .font(.system(size: 20).bold())
                            .foregroundStyle(.black)
                    }
                }.padding()
                
                // Labels
                VStack {
                    HStack(spacing: 10) {
                        statBlock(
                            icon: "tray.full.fill",
                            value: "\(studiedCardsCount) Cards",
                            label: "Cards studied",
                            event: "profile_cards_studied_tap"
                        )
                        
                        statBlock(
                            icon: "flame",
                            value: "\(currentStreak) Days",
                            label: "Coming back",
                            event: "profile_streak_tap"
                        )
                    }
                    
                    HStack(spacing: 10) {
                        statBlock(
                            icon: "timer",
                            value: formattedTimeSpent,
                            label: "Time Studied",
                            event: "profile_time_studied_tap"
                        )
                        
                        statBlock(
                            icon: "bolt",
                            value: "\(starsCount) Stars",
                            label: "Experience",
                            event: "profile_experience_tap"
                        )
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            screenEnterTime = Date()
            lastActionTime = Date()
            Analytics.logEvent("profile_screen_appear", parameters: nil)
            fetchStudiedCardsCount()
        }
        .onDisappear {
            if let enter = screenEnterTime {
                let duration = Date().timeIntervalSince(enter)
                Analytics.logEvent("profile_screen_disappear", parameters: [
                    "duration_seconds": duration
                ])
            }
        }
    }
    
    // MARK: - Block View
    private func statBlock(icon: String, value: String, label: String, event: String) -> some View {
        Button {
            logAction(event: event)
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(hex: "#546a50").opacity(0.2))
                    .frame(width: 180, height: 150)
                    .clipShape(.rect(cornerRadius: 20))
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: icon)
                            .foregroundColor(Color(hex: "#546a50").opacity(0.6))
                            .font(.system(size: 19).bold())
                            .padding(.leading)
                            .padding(.bottom, -6)
                        Spacer()
                    }
                    
                    HStack {
                        Text(value)
                            .foregroundColor(Color(hex: "#546a50"))
                            .font(.system(size: 30).bold())
                            .padding(.leading)
                        Spacer()
                    }
                    
                    HStack {
                        Text(label)
                            .foregroundColor(Color(hex: "#546a50"))
                            .font(.system(size: 14).bold())
                            .padding(.leading)
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Analytics
    private func logAction(event: String) {
        let now = Date()
        if let last = lastActionTime {
            let interval = now.timeIntervalSince(last)
            Analytics.logEvent(event, parameters: [
                "interval_since_last_action": interval
            ])
        } else {
            Analytics.logEvent(event, parameters: nil)
        }
        lastActionTime = now
    }
    
    private func fetchStudiedCardsCount() {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isNew == false")
        do {
            let count = try viewContext.count(for: request)
            studiedCardsCount = count
            starsCount = max(0, count / 10)
            
            Analytics.logEvent("profile_data_loaded", parameters: [
                "studied_cards": count,
                "stars_count": starsCount,
                "current_streak": currentStreak,
                "total_time_spent_minutes": Int(totalTimeSpent) / 60
            ])
        } catch {
            print("Ошибка при подсчёте изученных карточек: \(error)")
            studiedCardsCount = 0
        }
    }
    
    private var formattedTimeSpent: String {
        let totalSeconds = Int(totalTimeSpent)
        let minutes = totalSeconds / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) h \(remainingMinutes) min"
        }
    }
}

#Preview {
    ProfileView()
}

/*
struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var studiedCardsCount = 0
    @State private var starsCount = 0
    @AppStorage("totalTimeSpent") private var totalTimeSpent: Double = 0
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#ddead1")
                .ignoresSafeArea()
            
            VStack {
                
                // User avatar, name
                VStack {
                    Image("icon_image")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(hex: "#546a50").opacity(0.5))
                        .cornerRadius(55)
                    
                    Text("Anonymous User")
                        .font(.system(size: 20).bold())
                }.padding()
                
                // Button "Login" (in develop)
                VStack {
                    
                }
                
                // Labels
                VStack {
                    HStack(spacing: 10) {
                        // Cards Studied
                        VStack {
                            ZStack {
                                // back
                                Rectangle()
                                    .foregroundColor(Color(hex: "#546a50").opacity(0.2))
                                    .frame(width: 180, height: 150)
                                    .clipShape(.rect(cornerRadius: 20))
                                
                                VStack(spacing: 20) {
                                    HStack {
                                        Image(systemName: "tray.full.fill")
                                            .foregroundColor(Color(hex: "#546a50").opacity(0.6))
                                            .font(.system(size: 16).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("\(studiedCardsCount) Cards")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 30).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Cards studied")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 14).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                }
                                
                            }
                        }
                        
                        // Coming back "fire"
                        VStack {
                            ZStack {
                                // back
                                Rectangle()
                                    .foregroundColor(Color(hex: "#546a50").opacity(0.2))
                                    .frame(width: 180, height: 150)
                                    .clipShape(.rect(cornerRadius: 20))
                                
                                VStack(spacing: 20) {
                                    HStack {
                                        Image(systemName: "flame")
                                            .foregroundColor(Color(hex: "#546a50").opacity(0.6))
                                            .font(.system(size: 19).bold())
                                            .padding(.leading)
                                            .padding(.bottom, -6)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("\(currentStreak) Days")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 30).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Coming back")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 14).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 10) {
                        // Time Studied
                        VStack {
                            ZStack {
                                // back
                                Rectangle()
                                    .foregroundColor(Color(hex: "#546a50").opacity(0.2))
                                    .frame(width: 180, height: 150)
                                    .clipShape(.rect(cornerRadius: 20))
                                
                                VStack(spacing: 20) {
                                    HStack {
                                        Image(systemName: "timer")
                                            .foregroundColor(Color(hex: "#546a50").opacity(0.6))
                                            .font(.system(size: 19).bold())
                                            .padding(.leading)
                                            .padding(.bottom, -6)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text(formattedTimeSpent)
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 30).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Time Studied")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 14).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                }
                                
                            }
                        }
                        
                        // Experience (Star = number of ready day quest)
                        VStack {
                            ZStack {
                                // back
                                Rectangle()
                                    .foregroundColor(Color(hex: "#546a50").opacity(0.2))
                                    .frame(width: 180, height: 150)
                                    .clipShape(.rect(cornerRadius: 20))
                                
                                VStack(spacing: 20) {
                                    HStack {
                                        Image(systemName: "bolt")
                                            .foregroundColor(Color(hex: "#546a50").opacity(0.6))
                                            .font(.system(size: 19).bold())
                                            .padding(.leading)
                                            .padding(.bottom, -6)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("\(starsCount) Stars")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 30).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Experience")
                                            .foregroundColor(Color(hex: "#546a50"))
                                            .font(.system(size: 14).bold())
                                            .padding(.leading)
                                        
                                        Spacer()
                                    }
                                }
                                
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            fetchStudiedCardsCount()
        }
    }
    
    private func fetchStudiedCardsCount() {
        let request: NSFetchRequest<Card> = Card.fetchRequest()
        request.predicate = NSPredicate(format: "isNew == false")

        do {
            let count = try viewContext.count(for: request)
            studiedCardsCount = count
            
            starsCount = max(0, count / 20)
        } catch {
            print("Ошибка при подсчёте изученных карточек: \(error)")
            studiedCardsCount = 0
        }
    }
    
    private var formattedTimeSpent: String {
        let totalSeconds = Int(totalTimeSpent)
        let minutes = totalSeconds / 60
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours) h \(remainingMinutes) min"
        }
    }

}


#Preview {
    ProfileView()
 }*/
