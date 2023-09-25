//
//  File.swift
//  
//
//  Created by Jim Conroy on 25/9/2023.
//

import Foundation
import OpenAI

struct OpenAIChatProvider: ChatProvider {
    let openAI: OpenAI
    let temperature: OpenAIChatTemperature
    let model: String       // e.g. "gpt-3.5-turbo"
    let maxTokens: Int?
    let userID: String?
    
    public func performChat(withMessages messages: [Message]) async throws -> Message {
        
        // Prepare Chats and Query from given [Message]
        let systemPrompt = messages.first { !$0.isUser }?.text ?? ""
        let chats = [Chat(role: .system, content: systemPrompt)] + messages.map { Chat(role: $0.isUser ? .user : .assistant, content: $0.text) }
        
        // Prepare your query here according to your OpenAI SDK and your needs.
        let query = ChatQuery(
            model: model, // Assuming this is the model you want to use.
            messages: chats,
            functions: nil,
            functionCall: nil,
            temperature: temperature.temperature,
            maxTokens: maxTokens,
            user: userID
        )
        
        do {
            // Perform the actual OpenAI chat
            let result = try await openAI.chats(query: query)
            
            // Transform the result to [Message] and return the latest one.
            guard let text = result.choices.first?.message.content else {
                throw NSError(domain: "OpenAI", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            return Message(text: text, isUser: false)
        } catch {
            // Propagate the error to the caller.
            throw error
        }
    }
}
