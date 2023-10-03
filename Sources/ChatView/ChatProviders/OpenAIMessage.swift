//
//  File.swift
//  
//
//  Created by Jim Conroy on 3/10/2023.
//

import Foundation
import OpenAI

public struct OpenAIMessage: Message {
    public let id: UUID
    public let text: String
    public let role: MessageRole
    public let isReceiving: Bool
    public let isError: Bool
    public let isHidden: Bool
    
    public init(
        id: UUID = UUID(),
        text: String,
        role: MessageRole,
        isReceiving: Bool = false,
        isError: Bool = false,
        isHidden: Bool = false
    ) {
        self.id = id
        self.text = text
        self.role = role
        self.isReceiving = isReceiving
        self.isError = isError
        self.isHidden = isHidden
    }
    
    public func copyWith(
        id: UUID? = nil, text: String? = nil, role: MessageRole? = nil,
        isReceiving: Bool? = nil, isError: Bool? = nil, isHidden: Bool? = nil
    ) -> OpenAIMessage {
        OpenAIMessage(
            id: id ?? self.id,
            text: text ?? self.text,
            role: role ?? self.role,
            isReceiving: isReceiving ?? self.isReceiving,
            isError: isError ?? self.isError,
            isHidden: isHidden ?? self.isHidden
        )
    }
}

public extension OpenAIMessage {
    var openAIChatRole: Chat.Role {
        get {
            switch role {
            case .assistant:
                return Chat.Role.assistant
            case .system:
                return Chat.Role.system
            case .user:
                return Chat.Role.user
            case .function:
                return Chat.Role.function
            }
        }
    }
    
    var openAIChat: Chat {
        return Chat(role: self.openAIChatRole, content: self.text)
    }
}
