//
//  Message.swift
//
//  Created by Jamie Conroy on 1/9/2023.
//

import Foundation


public enum MessageRole {
    case system
    case assistant
    case user
    case function
}

/**
 `ChatProvider` is an open class that provides a base for chat providers. It uses generics to allow for different types of messages, provided they conform to the `Message` protocol.

 The class provides a single method `performChat(withMessages:)` that should be overridden by subclasses to perform a chat with the given messages.

 `MessageRole` is an enum that represents the role of a message in a chat. It can be one of four values: `system`, `assistant`, `user`, or `function`.

 `Message` is a protocol that represents a message in a chat. It requires several properties:
 - `id`: A unique identifier for the message.
 - `text`: The text of the message.
 - `role`: The role of the message.
 - `isReceiving`: A boolean indicating whether the message is being received.
 - `isError`: A boolean indicating whether the message is an error message.
 - `isHidden`: A boolean indicating whether the message is hidden.

 The protocol also requires an initializer and a `copyWith(id:text:role:isReceiving:isError:isHidden:)` method for creating a copy of a message with some properties potentially changed.
 */
public protocol Message: Identifiable, Equatable {
    var id: UUID { get }
    var text: String { get }
    var role: MessageRole { get }
    var isReceiving: Bool { get }
    var isError: Bool { get }
    var isHidden: Bool { get }
    
    init(id: UUID, text: String, role: MessageRole, isReceiving: Bool, isError: Bool, isHidden: Bool)
    
    func copyWith(
        id: UUID?, text: String?, role: MessageRole?,
        isReceiving: Bool?, isError: Bool?, isHidden: Bool?
    ) -> Self
}
