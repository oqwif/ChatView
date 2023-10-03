//
//  File.swift
//  
//
//  Created by Jim Conroy on 25/9/2023.
//

import Foundation
import OpenAI

public enum OpenAIChatProviderError: Error {
    case invalidResponse
    case maxTokensExceeded
    case contentFilterException
    case noResponseMessageContent
    case other(String)  // Generic error type for other unforeseen errors
    
    public var localizedDescription: String {
        switch self {
        case .invalidResponse:
            return "Invalid response from API."
        case .maxTokensExceeded:
            return "The maximum number of tokens specified in the request was reached."
        case .contentFilterException:
            return "Content was omitted due to a flag from API content filters."
        case .noResponseMessageContent:
            return "No content was received in the message returned from the API."
        case .other(let message):
            return message
        }
    }
}


public class OpenAIChatProvider: ChatProvider {
    let openAI: OpenAI
    let temperature: OpenAIChatTemperature
    let model: String       // e.g. "gpt-3.5-turbo"
    let maxTokens: Int?
    let userID: String?
    let functions: [ChatFunctionDeclaration]?
    
    public init(openAI: OpenAI, temperature: OpenAIChatTemperature = .creativeWriting, model: String = "gpt-3.5-turbo", maxTokens: Int? = nil, userID: String? = nil, functions: [ChatFunctionDeclaration]? = nil) {
        self.openAI = openAI
        self.temperature = temperature
        self.model = model
        self.maxTokens = maxTokens
        self.userID = userID
        self.functions = functions
    }
    
    public func performChat(withMessages messages: [any Message]) async throws -> any Message {
        guard let messages = messages as? [OpenAIMessage] else {
            fatalError("messages are not of type OpenAIMessage")
        }
        let chats = messages.map { $0.openAIChat }
        
        let query = ChatQuery(
            model: model,
            messages: chats,
            functions: functions,
            functionCall: nil,
            temperature: temperature.temperature,
            maxTokens: maxTokens,
            user: userID
        )
        
        do {
            // Perform the actual OpenAI chat
            let result = try await openAI.chats(query: query)
            
            // Get the first choice from the response
            guard let firstChoice = result.choices.first else {
                throw OpenAIChatProviderError.invalidResponse
            }
            
            guard firstChoice.finishReason != "length" else {
                throw OpenAIChatProviderError.maxTokensExceeded
            }
            
            guard firstChoice.finishReason != "content_filter" else {
                throw OpenAIChatProviderError.contentFilterException
            }
            
//            if firstChoice.finishReason == "function_call" {
//                chat = Chat(role: .assistant, )
//            }
            
            // Transform the result to [Message] and return the latest one.
            guard let text = result.choices.first?.message.content else {
                throw OpenAIChatProviderError.noResponseMessageContent
            }
            
            return OpenAIMessage(text: text, role: .assistant)
        } catch {
            // Propagate the error to the caller.
            throw error
        }
    }
}
