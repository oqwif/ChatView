//
//  ChatViewModel.swift
//
//  Created by Jim Conroy on 5/9/2023.
//

import Foundation
import OpenAI  // https://github.com/MacPaw/OpenAI

enum ChatViewModelError: Error {
    case notConnected
    case other(String)
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?
    
    let systemPrompt: String
    let userID: String?
    let triggers: [ChatResponseTrigger]?
    
    private let openAI: OpenAI
    private let model: String
    
    init(systemPrompt: String, token: String, userID: String? = nil, triggers: [ChatResponseTrigger]? = nil) {
        self.systemPrompt = systemPrompt
        self.userID = userID
        self.triggers = triggers
        self.model = Bundle.main.infoDictionary?["OpenAIModel"] as? String ?? "gpt-3.5-turbo"
        
        let host = Bundle.main.infoDictionary?["OpenAIHost"] as? String ?? "api.openai.com"
        let configuration = OpenAI.Configuration(token: token, host: host, timeoutInterval: 90)
        self.openAI = OpenAI(configuration: configuration)
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
                try await callChatGPT()
            } catch {
                handleGPTError(error)
            }
        }
    }
    
    private func callChatGPT() async throws {
        updateOnMain {
            self.messages.append(Message(text: "", isUser: false, isReceiving: true))
        }
        
        let chats = prepareChats()
        let query = prepareQuery(chats: chats)
        
        do {
            let result = try await openAI.chats(query: query)
            processGPTResult(result)
        } catch {
            handleGPTError(error)
        }
    }
    
    private func prepareChats() -> [Chat] {
        return [Chat(role: .system, content: systemPrompt)] + messages.map { Chat(role: $0.isUser ? .user : .assistant, content: $0.text) }
    }
    
    private func prepareQuery(chats: [Chat]) -> ChatQuery {
        return ChatQuery(
            model: self.model,
            messages: chats,
            functions: nil,
            functionCall: nil,
            temperature: 0.4,
            maxTokens: 500,
            user: userID
        )
    }
    
    private func processGPTResult(_ result: ChatResult) {
        guard let text = result.choices.first?.message.content else {
            updateOnMain {
                self.errorMessage = "There was an error receiving the response. Please try again."
            }
            return
        }
        
        updateOnMain {
            let message = self.messages[self.messages.count - 1]
            self.messages[self.messages.count - 1] = message.copyWith(text: text, isReceiving: false)
            self.triggers?.forEach { trigger in
                if trigger.shouldActivate(forChatResponse: text) {
                    trigger.activate()
                }
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

