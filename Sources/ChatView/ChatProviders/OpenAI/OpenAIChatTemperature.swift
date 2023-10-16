//
//  File.swift
//  
//
//  Created by Jamie Conroy on 25/9/2023.
//

import Foundation

public enum OpenAIChatTemperature: String, CaseIterable {
    case codeGeneration = "Code Generation"
    case creativeWriting = "Creative Writing"
    case chatbotResponses = "Chatbot Responses"
    case codeCommentGeneration = "Code Comment Generation"
    case dataAnalysisScripting = "Data Analysis Scripting"
    case exploratoryCodeWriting = "Exploratory Code Writing"
    
    var temperature: Double {
        switch self {
        case .codeGeneration, .dataAnalysisScripting:
            return 0.2
        case .codeCommentGeneration:
            return 0.3
        case .chatbotResponses:
            return 0.5
        case .exploratoryCodeWriting:
            return 0.6
        case .creativeWriting:
            return 0.7
        }
    }
    
    var topP: Double {
        switch self {
        case .codeGeneration, .dataAnalysisScripting:
            return 0.1
        case .codeCommentGeneration:
            return 0.2
        case .chatbotResponses:
            return 0.5
        case .exploratoryCodeWriting:
            return 0.7
        case .creativeWriting:
            return 0.8
        }
    }
    
    var description: String {
        switch self {
        case .codeGeneration:
            return "Generates code that adheres to established patterns and conventions. Output is more deterministic and focused. Useful for generating syntactically correct code."
        case .creativeWriting:
            return "Generates creative and diverse text for storytelling. Output is more exploratory and less constrained by patterns."
        case .chatbotResponses:
            return "Generates conversational responses that balance coherence and diversity. Output is more natural and engaging."
        case .codeCommentGeneration:
            return "Generates code comments that are more likely to be concise and relevant. Output is more deterministic and adheres to conventions."
        case .dataAnalysisScripting:
            return "Generates data analysis scripts that are more likely to be correct and efficient. Output is more deterministic and focused."
        case .exploratoryCodeWriting:
            return "Generates code that explores alternative solutions and creative approaches. Output is less constrained by established patterns."
        }
    }
}

