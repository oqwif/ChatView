//
//  ChatViewModel.swift
//
//  Created by Jamie Conroy on 5/9/2023.
//

import Foundation
import SwiftUI

enum ChatViewModelError: LocalizedError {
    case notConnected
    case functionStreamError(String)
    case streamError(String)
    case other(String)
    
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "ChatViewModelError: Not connected"
        case .functionStreamError(let message):
            return "ChatViewModelError: Function stream error: \(message)"
        case .streamError(let message):
            return "ChatViewModelError: Stream error: \(message)"
        case .other(let message):
            return "ChatViewModelError: \(message)"
        }
    }
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
open class ChatViewModel<MessageType: Message>: ObservableObject {
    @Published public var messages: [MessageType] = []
    @Published public var newMessage: String = ""
    @Published public var shouldFocusTextField: Bool = false

    @Published var errorMessage: String?
    @Published var isMessageViewTapped: Bool = false
    @Published var chatStarted: Bool = false
    @Published var isReceiving: Bool = false
    
    public let chatProvider: ChatProvider<MessageType>
    private let stream: Bool
    
    public init(chatProvider: ChatProvider<MessageType>, messages: [MessageType] = [], stream: Bool = false) {
        self.chatProvider = chatProvider
        self.messages = messages
        self.stream = stream
    }
    
    // MARK: - Public Methods
    
    public func startChat() {
        guard isReceiving == false else {
            return
        }
        
        self.chatStarted = true
        
        callChatProvider()
    }
    
    func sendMessage() {
        guard isReceiving == false else {
            return
        }

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
        guard isReceiving == false else {
            return
        }
        Task {
            await addCall(message)
        }
    }
    
    // Method to request focus
    public func requestFocusOnTextField() {
        shouldFocusTextField = true
    }

    // Method to clear focus request
    public func clearFocusRequest() {
        shouldFocusTextField = false
    }

    @MainActor
    private func addCall(_ message: MessageType) async {
        chatStarted = chatStarted ? true : message.isHidden == false && message.role == .user
        messages.append(message)
        callChatProvider()
    }
    
    public func retry() {
        guard isReceiving == false else {
            return
        }
        Task {
            await retryCall()
        }
    }
    
    @MainActor
    private func retryCall() async {
        guard let lastMessage = messages.last(where: { $0.isError }) else { return }
        if let index = messages.firstIndex(of: lastMessage) {
            messages.remove(at: index)
        }
        callChatProvider()
    }
    
    @MainActor
    public func resetChat(messages: [MessageType]? = nil) {
        guard isReceiving == false else {
            return
        }

        chatStarted = false
        if let messages = messages {
            self.messages = messages
        } else {
            self.messages.removeAll { $0.role != .system }
        }
    }
    
    // MARK: - Private Methods
    
    private func callChatProvider() {
        Task {
            await updateOnMain {
                self.messages.append(MessageType(id: UUID(), text: "", role: .assistant, isReceiving: true, isError: false, isHidden: false))
                self.newMessage = ""
                self.isReceiving = true
            }
            do {
                if(!stream) {
                    let newMessages = try await self.fetchChatResponsesUntilNonFunction(messages: self.messages)
                    await updateOnMain {
                        self.messages = newMessages
                    }
                } else {
                    try await self.streamFetchChatResponses(with: self.messages)
                }
                await updateOnMain {
                    self.isReceiving = false
                }
            } catch {
                await updateOnMain {
                    self.messages = self.messages.filter { !$0.isReceiving }
                }
                handleChatProviderError(error)
                await updateOnMain {
                    self.isReceiving = false
                }
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
    
    private func streamFetchChatResponses(with initialMessages: [MessageType]) async throws {
        let inMessages = initialMessages
        do {
            for try await newMessage in chatProvider.performStreamChat(withMessages: inMessages.filter{!$0.isReceiving}) {
                var updatedMessages = inMessages
                if newMessage.role == .function {
                    do {
                        updatedMessages[updatedMessages.count-1] = newMessage
                        updatedMessages.append(MessageType(id: UUID(), text: "", role: .assistant, isReceiving: true, isError: false, isHidden: false))
                        await updateOnMain {
                            self.messages = updatedMessages
                        }
                        try await streamFetchChatResponses(with: updatedMessages)
                    }
                    catch {
                        throw ChatViewModelError.streamError(error.localizedDescription)
                    }
                } else {
                    updatedMessages[updatedMessages.count-1] = newMessage
                    await updateOnMain {
                        self.messages = updatedMessages
                    }
                }
            }
        } catch {
            throw ChatViewModelError.streamError(error.localizedDescription)
        }
    }

    
    private func handleChatProviderError(_ error: Error) {
        DispatchQueue.main.async {
            let localizedDescription = error.localizedDescription
            self.errorMessage = "An error occurred: \(localizedDescription)"
        }
    }
    
    func updateOnMain(_ block: @escaping () -> Void) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                block()
                continuation.resume()
            }
        }
    }
}

