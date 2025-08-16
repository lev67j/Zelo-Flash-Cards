//
//  AIChatVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-12.
//

import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var systemPrompt: String = ""
    
    private let apiKey = "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"
    private let model = "deepseek/deepseek-r1"

    func sendMessage() {
        let userMessage = Message(role: "user", content: currentInput)
        messages.append(userMessage)
        let prompt = currentInput
        currentInput = ""

        Task {
            if let reply = await callOpenRouterAPI(prompt: prompt) {
                DispatchQueue.main.async {
                    self.messages.append(Message(role: "assistant", content: reply))
                }
            }
        }
    }

    private func callOpenRouterAPI(prompt: String) async -> String? {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else { return nil }
        
        var messageHistory: [[String: String]] = []
        if !systemPrompt.isEmpty {
            messageHistory.append(["role": "system", "content": systemPrompt])
        }
        messageHistory += messages.map { ["role": $0.role, "content": $0.content] }
        messageHistory.append(["role": "user", "content": prompt])
        
        let payload: [String: Any] = [
            "model": model,
            "messages": messageHistory
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            request.httpBody = data
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            }
        } catch {
            print("Error: \(error)")
        }
        
        return nil
    }
}

struct Message: Identifiable {
    let id = UUID()
    let role: String // "user" или "assistant"
    let content: String
}
