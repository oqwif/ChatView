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
    
    private let chatProvider: ChatProvider<MessageType>
    
    public init(chatProvider: ChatProvider<MessageType>, messages: [MessageType] = []) {
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
            self.newMessage = ""
        }
        Task {
            do {
                let newMessages = try await self.handleCall(messages: self.messages)
                updateOnMain {
                    self.messages = newMessages
                }
            } catch {
                handleGPTError(error)
            }
        }
    }
    
    // can return multiple messages
    private func handleCall(messages: [MessageType] = []) async throws -> [MessageType] {
        var newMessages = messages.filter{!$0.isReceiving}
        let message = try await chatProvider.performChat(withMessages: newMessages)

        newMessages.append(message)
        if message.role == .function {
            // If it is a function result, call GPT again so that it can see the result
            return try await handleCall(messages: newMessages)
        } else {
            return newMessages
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

