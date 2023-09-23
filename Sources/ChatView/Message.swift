//
//  Message.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import Foundation

public struct Message: Identifiable, Equatable {
    public var id = UUID()
    var text: String
    var isUser: Bool  // true for user's messages, false for other's messages
    var isReceiving: Bool = false
    var isError: Bool = false
    
    func copyWith(id: UUID? = nil, text: String? = nil, isUser: Bool? = nil, isReceiving: Bool? = nil, isError: Bool? = nil) -> Message {
        return Message(
            id: id ?? self.id,
            text: text ?? self.text,
            isUser: isUser ?? self.isUser,
            isReceiving: isReceiving ?? self.isReceiving,
            isError: isError ?? self.isError
        )
    }
}

extension Message {
    static var sampleMessages: [Message] {
        return [
            Message(text: "Hello! How's it going?", isUser: false),
            Message(text: "Hi there! I'm good, thanks for asking. How about you?", isUser: true),
            Message(text: "I'm doing well! Have you seen the new movie that just came out?", isUser: false),
            Message(text: "Not yet, but I've heard great reviews about it.", isUser: true),
            Message(text: "You should definitely check it out. It's worth it!", isUser: false),
            Message(text: "", isUser: false, isReceiving: true),
            Message(text: "", isUser: false, isError: true)
        ]
    }
}
