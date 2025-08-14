//
//  AIChatView.swift
//  Zelo Cards
//
//  Created by Lev Vlasov on 2025-06-21.
//
import SwiftUI


struct AIChatView: View {
    @StateObject private var vm = ChatViewModel()

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

#Preview {
    AIChatView()
}
