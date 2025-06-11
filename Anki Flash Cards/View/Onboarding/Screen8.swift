//
//  ScreenEight.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-07.
//

import StoreKit
import SwiftUI
import CoreData

// Восьмой экран - запрос рейтинга
struct EighthScreen: View {
    @Binding var currentPage: Int
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Leave a rating to help us improve!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Блок с отзывом
            VStack {
                Image("image 1 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .shadow(radius: 1)
            }
            .padding()
            .padding(.horizontal)

            // Блок с App Store рейтингом
            HStack {
                Image("image 2 for eight screen")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
            }
            .padding(.horizontal)

            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}
