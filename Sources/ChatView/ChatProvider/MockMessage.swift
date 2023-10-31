//
//  File.swift
//  
//
//  Created by Jamie Conroy on 3/10/2023.
//

import Foundation

struct MockMessage: Message {
    var id: UUID = UUID()
    var text: String
    var role: MessageRole
    var isReceiving: Bool = false
    var isError: Bool = false
    var isHidden: Bool = false
    
    func copyWith(
        id: UUID? = nil, text: String? = nil, role: MessageRole? = nil,
        isReceiving: Bool? = nil, isError: Bool? = nil, isHidden: Bool? = nil
    ) -> MockMessage {
        MockMessage(
            id: id ?? self.id,
            text: text ?? self.text,
            role: role ?? self.role,
            isReceiving: isReceiving ?? self.isReceiving,
            isError: isError ?? self.isError,
            isHidden: isHidden ?? self.isHidden
        )
    }
}

extension MockMessage {
    static var sampleMessages: [MockMessage] {
        return [
            MockMessage(text: "Hello! How's it going?", role: .assistant),
            MockMessage(text: "Hi there! I'm good, thanks for asking. How about you?", role: .user),
            MockMessage(text: "I'm doing well! Have you seen the new movie that just came out?", role: .assistant),
            MockMessage(text: "Not yet, but I've heard great reviews about it.", role: .user),
            MockMessage(text: "You should definitely check it out. It's *worth it!*", role: .assistant),
            MockMessage(text: "Check out this [Link](https://getitdoneai.com). It's worth it!", role: .assistant),
            MockMessage(text: "How about this title:\n## Hey There!", role: .assistant),
            MockMessage(text: "", role: .assistant, isReceiving: true),
            MockMessage(text: "", role: .assistant, isError: true)
        ]
    }
}
