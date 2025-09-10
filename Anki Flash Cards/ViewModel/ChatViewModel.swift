//
//  AIChatVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-12.
//

import SwiftUI
import CoreData

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var systemPrompt: String = ""
    @Published var isLoading: Bool = false
    
    private let apiKey = "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"
    private let model = "deepseek/deepseek-chat-v3.1:free"
    
    var managedObjectContext: NSManagedObjectContext?
    var currentUser: User?

    func loadMessages() {
        guard let context = managedObjectContext, let user = currentUser else { return }
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let coreDataMessages = try context.fetch(fetchRequest)
            self.messages = coreDataMessages.map { ChatMessage(role: $0.role ?? "", content: $0.content ?? "", timestamp: $0.timestamp ?? Date()) }
        } catch {
            print("Error loading messages: \(error)")
        }
    }
    
    private func saveMessage(_ chatMessage: ChatMessage) {
        guard let context = managedObjectContext, let user = currentUser else { return }
        
        let newMessage = Message(context: context)
        newMessage.id = chatMessage.id
        newMessage.role = chatMessage.role
        newMessage.content = chatMessage.content
        newMessage.timestamp = chatMessage.timestamp
        newMessage.user = user
        
        do {
            try context.save()
        } catch {
            print("Error saving message: \(error)")
        }
    }

    func sendMessage() {
        let userMessage = ChatMessage(role: "user", content: currentInput, timestamp: Date())
        messages.append(userMessage)
        saveMessage(userMessage)
        currentInput = ""
        
        isLoading = true
        
        Task {
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let reply = await generateResponse() {
                let assistantMessage = ChatMessage(role: "assistant", content: reply, timestamp: Date())
                DispatchQueue.main.async {
                    self.messages.append(assistantMessage)
                    self.saveMessage(assistantMessage)
                }
            } else {
                let errorMessage = ChatMessage(role: "assistant", content: "⚠️ Error while receiving response", timestamp: Date())
                DispatchQueue.main.async {
                    self.messages.append(errorMessage)
                    self.saveMessage(errorMessage)
                }
            }
        }
    }

    private func generateResponse() async -> String? {
        guard let url = URL(string: "https://openrouter.ai/api/v1/chat/completions") else {
            print("❌ Invalid URL")
            return nil
        }
        
        var messageHistory: [[String: String]] = []
        if !systemPrompt.isEmpty {
            messageHistory.append(["role": "system", "content": systemPrompt])
        }
        messageHistory += messages.map { ["role": $0.role, "content": $0.content] }
        
        let payload: [String: Any] = [
            "model": model,
            "messages": messageHistory,
            "temperature": 0.7,
            "top_p": 0.9,
            "max_tokens": 100000
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            print("📤 Payload JSON: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            print("🌐 Sending request to: \(url.absoluteString)")
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            if let httpResp = response as? HTTPURLResponse {
                print("✅ Received HTTP status: \(httpResp.statusCode)")
            }
            
            if let jsonString = String(data: responseData, encoding: .utf8) {
                print("📥 Response JSON: \(jsonString)")
            } else {
                print("❌ Failed to decode response as string")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                if let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    print("💬 Assistant reply: \(content)")
                    return content
                } else {
                    print("⚠️ JSON does not contain 'choices' or 'message'")
                }
            } else {
                print("❌ Failed to parse response JSON")
            }
        } catch {
            print("❌ Network or serialization error: \(error)")
        }
        
        return nil
    }

}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String
    let content: String
    let timestamp: Date
    
    init(role: String, content: String, timestamp: Date = Date()) {
        self.role = role
        self.content = content
        self.timestamp = timestamp
     }
}
