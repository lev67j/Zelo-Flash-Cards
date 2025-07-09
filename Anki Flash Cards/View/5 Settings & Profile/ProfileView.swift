//
//  ProfileView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CardCollection.creationDate, ascending: false)],
        animation: .default)
    private var collections: FetchedResults<CardCollection>
    
    @ObservedObject private var vm = DesignVM()
    
    @State private var studiedCardsCount = 0
    
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
                                        Text("14 Days")
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
                                        Text("55 min")
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
                                        Text("5 Stars")
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
        request.predicate = NSPredicate(format: "isNew == NO")
        
        do {
            let count = try viewContext.count(for: request)
            studiedCardsCount = count
        } catch {
            print("Ошибка при подсчёте изученных карточек: \(error)")
            studiedCardsCount = 0
        }
    }
}


#Preview {
    ProfileView()
}
