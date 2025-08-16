//
//  AIChatView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//
import SwiftUI

struct ChatView: View {
    let theme: String
    let vocabulary: String
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            List(viewModel.messages) { message in
                VStack(alignment: message.role == "user" ? .trailing : .leading) {
                    Text(message.content)
                        .padding()
                        .background(message.role == "user" ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            HStack {
                TextField("Type your message...", text: $viewModel.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    viewModel.sendMessage()
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.systemPrompt = "You are a helpful teacher. The user has just completed a lesson on the theme: \(theme). Their vocabulary includes: \(vocabulary). Ask a couple of questions one by one to test their knowledge on this theme, using the vocabulary. Wait for responses before asking the next question."
            viewModel.currentInput = "Start the quiz please."
            viewModel.sendMessage()
        }
    }
}

struct AIChatView: View {
    @StateObject private var vm = ChatViewModel()
    @Binding var cardsText: String
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vm.messages) { message in
                            HStack {
                                if message.role == "assistant" {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    Text(message.content)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { 
                    if let lastID = vm.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }

            HStack {
                TextField("Message...", text: $vm.currentInput, axis: .vertical)
                    .padding(8)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
                    .lineLimit(5)
                
                Button(action: vm.sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            .padding()
            .padding(.bottom, 70)
        }
        .navigationTitle("Chat")
    }
}
