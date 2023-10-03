//
//  ChatProvider.swift
//  
//
//  Created by Jim Conroy on 25/9/2023.
//

import Foundation

public protocol ChatProvider {
    func performChat(withMessages messages: [any Message]) async throws -> any Message
}
