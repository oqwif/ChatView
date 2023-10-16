//
//  File.swift
//  
//
//  Created by Jamie Conroy on 3/10/2023.
//

import Foundation
import OpenAI

public protocol OpenAIFunction {
    var chatFunctionDeclaration: ChatFunctionDeclaration { get }
    func call(parameters: [String:Any]) async throws -> Encodable
}
