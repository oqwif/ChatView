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

public class ChatViewModel<MessageType: Message>: ObservableObject {
    @Published var messages: [MessageType] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?
    @Published var isMessageViewTapped: Bool = false
    
    let triggers: [ChatResponseTrigger]?
    
    private let chatProvider: any ChatProvider
    
    public init(
        chatProvider: any ChatProvider,
        triggers: [ChatResponseTrigger]? = nil,
        messages: [MessageType] = []) {
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
        let userMessage = MessageType(
            id: UUID(),  // Provide a unique ID here
            text: newMessage,
            role: .user,
            isReceiving: false,
            isError: false,
            isHidden: false
        )
        add(message: userMessage)
        newMessage = ""
    }
    
    public func add(message: MessageType) {
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
    
    public func resetChat(messages: [MessageType]? = nil) {
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
            // need to refactor this out. I don't like how it adding a temp message
            self.messages.append(MessageType(id: UUID(), text: "", role: .assistant, isReceiving: true, isError: false, isHidden: false))
        }
        Task {
            do {
                let newMessage = try await chatProvider.performChat(withMessages: messages)
                guard let message = newMessage as? MessageType else {
                    fatalError("MessageType is incorrect")
                }
                updateOnMain {
                    self.messages[self.messages.count - 1] = message
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

