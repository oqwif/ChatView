//
//  File.swift
//  
//
//  Created by Jamie Conroy on 3/10/2023.
//

import Foundation
import OpenAI

public extension ChatQuery.ChatCompletionMessageParam {
    var messageRole: MessageRole {
        get {
            switch role {
            case .assistant:
                return .assistant
            case .system:
                return .system
            case .user:
                return .user
            case .tool:
                return .function
            }
        }
    }
}

public extension MessageRole {
    var chatRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .assistant:
            return ChatQuery.ChatCompletionMessageParam.Role.assistant
        case .system:
            return ChatQuery.ChatCompletionMessageParam.Role.system
        case .user:
            return ChatQuery.ChatCompletionMessageParam.Role.user
        case .function:
            return ChatQuery.ChatCompletionMessageParam.Role.tool
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
    public let chat: ChatQuery.ChatCompletionMessageParam
    
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
        self.chat = ChatQuery.ChatCompletionMessageParam(role: role.chatRole, content: text)!
    }
    
    public init(chat: ChatQuery.ChatCompletionMessageParam) {
        self.id = UUID()
        self.text = chat.content?.string ?? ""
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
