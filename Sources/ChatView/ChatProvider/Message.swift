//
//  Message.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import Foundation

public enum MessageRole {
    case system
    case assistant
    case user
    case function
}

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
