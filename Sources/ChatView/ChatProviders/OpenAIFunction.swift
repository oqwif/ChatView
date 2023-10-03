//
//  File.swift
//  
//
//  Created by Jim Conroy on 3/10/2023.
//

import Foundation
import OpenAI

public protocol OpenAIFunction {
    var chatFunctionDeclaration: ChatFunctionDeclaration { get }
    func call(arguments: String) -> String
}
