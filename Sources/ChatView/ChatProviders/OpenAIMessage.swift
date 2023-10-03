//
//  File.swift
//  
//
//  Created by Jim Conroy on 3/10/2023.
//

import Foundation
import OpenAI

public extension Chat {
    var messageRole: MessageRole {
        get {
            switch role {
            case .assistant:
                return .assistant
            case .system:
                return .system
            case .user:
                return .user
            case .function:
                return .function
            }
        }
    }
}

public extension MessageRole {
    var chatRole: Chat.Role {
        switch self {
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

public struct OpenAIMessage: Message {
    public let id: UUID
    public let text: String
    public let role: MessageRole
    public let isReceiving: Bool
    public let isError: Bool
    public let isHidden: Bool
    public let chat: Chat
    
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
        self.chat = Chat(role: role.chatRole, content: text)
    }
    
    public init(chat: Chat) {
        self.id = UUID()
        self.text = chat.content ?? ""
        self.role = chat.messageRole
        self.isReceiving = false
        self.isError = false
        self.isHidden = chat.messageRole == .function
        self.chat = chat
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
