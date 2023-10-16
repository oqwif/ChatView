//
//  ChatProvider.swift
//  
//
//  Created by Jim Conroy on 25/9/2023.
//

import Foundation

open class ChatProvider<MessageType: Message> {
    open func performChat(withMessages messages: [MessageType]) async throws -> MessageType {
        fatalError("This method should be overridden")
    }
}
