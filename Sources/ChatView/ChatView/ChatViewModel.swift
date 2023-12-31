//
//  ChatViewModel.swift
//
//  Created by Jamie Conroy on 5/9/2023.
//

import Foundation

enum ChatViewModelError: Error {
    case notConnected
    case other(String)
}

/**
 `ChatViewModel` is a class that acts as a view model for a chat interface. It uses generics to allow for different types of messages, provided they conform to the `Message` protocol. It is an `ObservableObject`, meaning that it can be observed for changes by SwiftUI views.

 This class contains several `@Published` properties which will trigger UI updates when changed:
 - `messages`: An array of messages of type `MessageType`.
 - `newMessage`: A string representing a new message that the user has typed but not yet sent.
 - `errorMessage`: A string representing any error messages that need to be displayed to the user.
 - `isMessageViewTapped`: A boolean indicating whether the message view has been tapped.

 The class also contains a `ChatProvider` instance, which is used to send and receive messages.

 The class provides several public methods for interacting with the chat:
 - `startChat()`: Starts the chat by calling the chat provider.
 - `sendMessage()`: Sends a new message, provided the `newMessage` property is not empty.
 - `add(message:)`: Adds a new message to the `messages` array and calls the chat provider.
 - `retry()`: Retries sending the last message that resulted in an error.
 - `resetChat(messages:)`: Resets the chat, optionally with a new set of messages.
 */
public class ChatViewModel<MessageType: Message>: ObservableObject {
    @Published var messages: [MessageType] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?
    @Published var isMessageViewTapped: Bool = false
    @Published var chatStarted: Bool = false
    
    private let chatProvider: ChatProvider<MessageType>
    private let stream: Bool
    
    public init(chatProvider: ChatProvider<MessageType>, messages: [MessageType] = [], stream: Bool = false) {
        self.chatProvider = chatProvider
        self.messages = messages
        self.stream = stream
    }
    
    // MARK: - Public Methods
    
    public func startChat() async {
        chatStarted = true
        callChatProvider()
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
        chatStarted = true
        messages.append(message)
        callChatProvider()
    }
    
    func retry() {
        guard let lastMessage = messages.last(where: { $0.isError }) else { return }
        if let index = messages.firstIndex(of: lastMessage) {
            messages.remove(at: index)
        }
        callChatProvider()
    }
    
    public func resetChat(messages: [MessageType]? = nil) {
        chatStarted = false
        if let messages = messages {
            self.messages = messages
        } else {
            self.messages.removeAll { $0.role != .system }
        }
    }
    
    // MARK: - Private Methods
    
    private func callChatProvider() {
        updateOnMain {
            self.messages.append(MessageType(id: UUID(), text: "", role: .assistant, isReceiving: true, isError: false, isHidden: false))
            self.newMessage = ""
        }
        Task {
            do {
                if(!stream) {
                    let newMessages = try await self.fetchChatResponsesUntilNonFunction(messages: self.messages)
                    updateOnMain {
                        self.messages = newMessages
                    }
                } else {
                    try await self.streamFetchChatResponses()
                }
                
            } catch {
                updateOnMain {
                    self.messages = self.messages.filter { !$0.isReceiving }
                }
                handleChatProviderError(error)
            }
        }
    }
    
    /**
     Fetches chat responses from the chat provider service until a non-function message is returned.
     
     - Parameters:
        - messages: An array of `MessageType` representing the initial set of messages to be sent to the chat provider. Defaults to an empty array.
     
     - Returns:
        An array of `MessageType` containing all the accumulated messages from the chat provider, including the non-function terminating message.
     
     - Throws:
        Throws an error if the chatProvider's `performChat` function throws an error.
     
     - Note:
        This function recursively sends messages and processes responses from the chat provider. If a response with a role of `.function` is received, the function will call itself again with the accumulated messages.
    */
    private func fetchChatResponsesUntilNonFunction(messages: [MessageType] = []) async throws -> [MessageType] {
        var newMessages = messages.filter{!$0.isReceiving}
        let message = try await chatProvider.performChat(withMessages: newMessages)

        newMessages.append(message)
        if message.role == .function {
            // If it is a function result, call GPT again so that it can see the result
            return try await fetchChatResponsesUntilNonFunction(messages: newMessages)
        } else {
            return newMessages
        }
    }
    
    private func streamFetchChatResponses() async throws {
        for try await newMessage in chatProvider.performStreamChat(withMessages: messages.filter{!$0.isReceiving}) {
            if newMessage.role == .function {
                DispatchQueue.main.sync {
                    self.messages[self.messages.count-1] = newMessage
                    self.messages.append(MessageType(id: UUID(), text: "", role: .assistant, isReceiving: true, isError: false, isHidden: false))
                }
                try await streamFetchChatResponses()
            } else {
                updateOnMain {
                    self.messages[self.messages.count-1] = newMessage
                }
            }
        }
    }
    
    private func handleChatProviderError(_ error: Error) {
        updateOnMain {
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    private func updateOnMain(_ update: @escaping () -> Void) {
        DispatchQueue.main.async(execute: update)
    }
}

