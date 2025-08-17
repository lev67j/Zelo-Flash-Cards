//
//  AIChatVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-12.
//

import SwiftUI

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var systemPrompt: String = ""
    @Published var isLoading: Bool = false
    
    private let apiKey = "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"
    private let model = "deepseek/deepseek-r1-0528:free"

    func sendMessage() {
        let userMessage = ChatMessage(role: "user", content: currentInput)
        messages.append(userMessage)
        currentInput = ""
        
        isLoading = true
        
        Task {
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let reply = await generateResponse() {
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(role: "assistant", content: reply))
                }
            } else {
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(role: "assistant", content: "⚠️ Error while receiving response"))
                }
            }
        }
    }

    private func generateResponse() async -> String? {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else { return nil }
        
        var messageHistory: [[String: String]] = []
        if !systemPrompt.isEmpty {
            messageHistory.append(["role": "system", "content": systemPrompt])
        }
        messageHistory += messages.map { ["role": $0.role, "content": $0.content] }
        
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

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String
    let content: String
    private let _attributedContent: NSAttributedString?
    
    var attributedContent: NSAttributedString {
        _attributedContent ?? content.parseMarkdownToAttributedString()
    }
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
        self._attributedContent = content.parseMarkdownToAttributedString()
    }
}
