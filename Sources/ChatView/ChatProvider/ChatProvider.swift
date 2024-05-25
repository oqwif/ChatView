//
//  ChatProvider.swift
//  
//
//  Created by Jamie Conroy on 25/9/2023.
//

import Foundation

/**
 `ChatProvider` is an open class that provides a base for implementing a chat provider. It uses generics to allow for different types of messages, provided they conform to the `Message` protocol.

 The class provides a single open method `performChat(withMessages:)` that should be overridden by subclasses. This method takes an array of messages as input and returns a single message asynchronously. The method throws an error if it is not overridden.
 */
open class ChatProvider<MessageType: Message> {
    open func performChat(withMessages messages: [MessageType]) async throws -> [MessageType] {
        fatalError("This method should be overridden")
    }
    open func performStreamChat(withMessages messages: [MessageType]) -> AsyncThrowingStream<MessageType, Error> {
        fatalError("This method should be overridden")
    }
}
