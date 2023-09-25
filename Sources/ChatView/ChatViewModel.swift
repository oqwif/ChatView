//
//  ChatViewModel.swift
//
//  Created by Jim Conroy on 5/9/2023.
//

import Foundation

enum ChatViewModelError: Error {
    case notConnected
    case other(String)
}

public class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?
    
    let systemPrompt: String
    let triggers: [ChatResponseTrigger]?
    
    private let chatProvider: any ChatProvider
    
    init(systemPrompt: String,
         chatProvider: any ChatProvider,
         triggers: [ChatResponseTrigger]? = nil,
         messages: [Message] = []) {
        self.systemPrompt = systemPrompt
        self.triggers = triggers
        self.chatProvider = chatProvider
        self.messages = messages
    }
    
    // MARK: - Public Methods
    
    func startChat() async {
        performChatGPTCall()
    }
    
    func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        add(message: Message(text: newMessage, isUser: true))
        newMessage = ""
    }
    
    func add(message: Message) {
        messages.append(message)
        performChatGPTCall()
    }
    
    func retry() {
        guard let lastMessage = messages.last(where: { $0.isError }) else { return }
        if let index = messages.firstIndex(of: lastMessage) {
            messages.remove(at: index)
        }
        performChatGPTCall()
    }
    
    // MARK: - Private Methods
    
    private func performChatGPTCall() {
        Task {
            do {
                let newMessage = try await chatProvider.performChat(withMessages: messages)
                updateOnMain {
                    self.messages.append(newMessage)
                }
            } catch {
                handleGPTError(error)
            }
        }
    }
//
//    private func processGPTResult(_ result: ChatResult) {
//        guard let text = result.choices.first?.message.content else {
//            updateOnMain {
//                self.errorMessage = "There was an error receiving the response. Please try again."
//            }
//            return
//        }
//
//        updateOnMain {
//            let message = self.messages[self.messages.count - 1]
//            self.messages[self.messages.count - 1] = message.copyWith(text: text, isReceiving: false)
//            self.triggers?.forEach { trigger in
//                if trigger.shouldActivate(forChatResponse: text) {
//                    trigger.activate()
//                }
//            }
//        }
//    }
    
    private func handleGPTError(_ error: Error) {
        updateOnMain {
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    private func updateOnMain(_ update: @escaping () -> Void) {
        DispatchQueue.main.async(execute: update)
    }
}

