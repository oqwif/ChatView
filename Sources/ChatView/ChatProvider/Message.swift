//
//  Message.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import Foundation

public enum Role {
    case system
    case assistant
    case user
}

public struct Message: Identifiable, Equatable {
    public let id: UUID
    public let text: String
    public let role: Role  // true for user's messages, false for other's messages
    public let isReceiving: Bool
    public let isError: Bool
    
    public init(id: UUID = UUID(), text: String, role: Role, isReceiving: Bool = false, isError: Bool = false) {
        self.id = id
        self.text = text
        self.role = role
        self.isReceiving = isReceiving
        self.isError = isError
    }
    
    func copyWith(id: UUID? = nil, text: String? = nil, role: Role? = nil, isReceiving: Bool? = nil, isError: Bool? = nil) -> Message {
        return Message(
            id: id ?? self.id,
            text: text ?? self.text,
            role: role ?? self.role,
            isReceiving: isReceiving ?? self.isReceiving,
            isError: isError ?? self.isError
        )
    }
}

extension Message {
    static var sampleMessages: [Message] {
        return [
            Message(text: "Hello! How's it going?", role: .assistant),
            Message(text: "Hi there! I'm good, thanks for asking. How about you?", role: .user),
            Message(text: "I'm doing well! Have you seen the new movie that just came out?", role: .assistant),
            Message(text: "Not yet, but I've heard great reviews about it.", role: .user),
            Message(text: "You should definitely check it out. It's worth it!", role: .assistant),
            Message(text: "", role: .assistant, isReceiving: true),
            Message(text: "", role: .assistant, isError: true)
        ]
    }
}
