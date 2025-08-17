//
//  ChatView.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-17.
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
                            }
                        } else {
                            Text(message.content)
                                .padding(12)
                                .foregroundColor(.black)
                        }
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#546a50")))
                                .scaleEffect(0.8)
                            Text("GPT is typing...")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
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
                    if !viewModel.currentInput.isEmpty {
                        viewModel.sendMessage()
                    }
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
            viewModel.systemPrompt = "You are helping a friend learn a language \(selectedLanguage) on the topic: \(theme). Your friend's vocabulary includes: \(vocabulary). You need to ask the following questions, ask them on your own without sleeping that you have a script, one after another, waiting for the user to answer before asking the next one. If the user asks another question, answer it, and then ask the next question from the list. Questions: \n\(questions.joined(separator: "\n")). You can chat with the user on any topic that interests them. You don't need to constantly focus on learning the language, you should weave language learning into a normal conversation with your friend. At the beginning of the message, indicate where the user made a mistake, and just ask questions one at a time. Don't write: Next Question: … Ask a question from yourself without a preface, like to a friend, you don't say: my next question is…, the user shouldn't understand that you have a list of questions. Please don't formatted your messages write defoult text without any formatting"
            if viewModel.messages.isEmpty && !questions.isEmpty {
                viewModel.messages.append(ChatMessage(role: "assistant", content: questions[0]))
            }
            
            print(viewModel.systemPrompt)
        }
    }
}
