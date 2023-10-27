//
//  TimeFunction.swift
//  AdventureChatView
//
//  Created by Jim Conroy on 27/10/2023.
//

import Foundation
import ChatView
import OpenAI

struct GetCurrentDateAndTimeFunction: OpenAIFunction {
    let chatFunctionDeclaration = ChatFunctionDeclaration (
        name: "get_date_and_time",
        description: "Returns the current date and time",
        parameters: JSONSchema(
            type: .object,
            properties: [:],
            required: []
        )
    )
        
    func call(parameters: [String : Any]) async throws -> Encodable {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        return ["date":dateFormatter.string(from: Date())]
    }
}
