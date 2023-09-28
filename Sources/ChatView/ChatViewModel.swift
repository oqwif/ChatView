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
    @Published var isMessageViewTapped: Bool = false
    
    let triggers: [ChatResponseTrigger]?
    
    private let chatProvider: any ChatProvider
    
    public init(
        chatProvider: any ChatProvider,
        triggers: [ChatResponseTrigger]? = nil,
        messages: [Message] = []) {
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
        add(message: Message(text: newMessage, role: .user))
        newMessage = ""
    }
    
    public func add(message: Message) {
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
    
    public func resetChat(messages: [Message]? = nil) {
        if let messages = messages {
            self.messages = messages
        } else {
            self.messages.removeAll { $0.role != .system }
        }
        performChatGPTCall()
    }
    
    // MARK: - Private Methods
    
    private func performChatGPTCall() {
        updateOnMain {
            self.messages.append(Message(text: "", role: .assistant, isReceiving: true))
        }
        Task {
            do {
                let newMessage = try await chatProvider.performChat(withMessages: messages)
                updateOnMain {
                    self.messages[self.messages.count - 1] = newMessage
                    self.triggers?.forEach { trigger in
                        if trigger.shouldActivate(forChatResponse: newMessage.text) {
                            trigger.activate()
                        }
                    }
                }
            } catch {
                handleGPTError(error)
            }
        }
    }
    
    private func handleGPTError(_ error: Error) {
        updateOnMain {
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    private func updateOnMain(_ update: @escaping () -> Void) {
        DispatchQueue.main.async(execute: update)
    }
}

