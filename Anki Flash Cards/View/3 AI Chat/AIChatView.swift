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
    let questions: [String]
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var design: DesignVM
    
    @AppStorage("selectedLanguage") var selectedLanguage = "English"
   

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        if message.role == "user" {
                            HStack {
                                Spacer()
                                Text(message.content)
                                    .padding(12)
                                    .background(Color(hex: "#546a50"))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
                            }
                        } else {
                            Text(message.content)
                                .padding(12)
                                .foregroundColor(.black)
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Type your message...", text: $viewModel.currentInput)
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button {
                    viewModel.sendMessage()
                } label: {
                    Circle()
                        .fill(Color(hex: "#546a50"))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.white)
                        )
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.systemPrompt = "You are helping a friend learn a language \(selectedLanguage) on the topic: \(theme). Your friend's vocabulary includes: \(vocabulary). You need to ask the following questions, ask them on your own without sleeping that you have a script, one after another, waiting for the user to answer before asking the next one. If the user asks another question, answer it, and then ask the next question from the list. Questions: \n\(questions.joined(separator: "\n")). You can chat with the user on any topic that interests them. You don't need to constantly focus on learning the language, you should weave language learning into a normal conversation with your friend. At the beginning of the message, indicate where the user made a mistake, and just ask questions one at a time."
            if viewModel.messages.isEmpty && !questions.isEmpty {
                viewModel.messages.append(Message(role: "assistant", content: questions[0]))
            }
            
            print(viewModel.systemPrompt)
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
