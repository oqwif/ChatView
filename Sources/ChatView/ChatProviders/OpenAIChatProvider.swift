//
//  File.swift
//
//
//  Created by Jim Conroy on 25/9/2023.
//

import Foundation
import OpenAI


public enum OpenAIChatProviderError: LocalizedError {
    case invalidResponse
    case maxTokensExceeded
    case contentFilterException
    case noResponseMessageContent
    case noFunctionNameSpecified
    case noArgumentsSpecified
    case noFunctionMatch(String)
    case other(String)  // Generic error type for other unforeseen errors
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from API."
        case .maxTokensExceeded:
            return "The maximum number of tokens specified in the request was reached."
        case .contentFilterException:
            return "Content was omitted due to a flag from API content filters."
        case .noResponseMessageContent:
            return "No content was received in the message returned from the API."
        case .noFunctionNameSpecified:
            return "The API tried to call a function but no name was specified"
        case .noArgumentsSpecified:
            return "The API tried to call a function but no arguments were specified"
        case .noFunctionMatch(let name):
            return "The API tried to call an unmatched function called \(name)."
        case .other(let message):
            return message
        }
    }
}

public enum FunctionCallError: LocalizedError {
    case unableToPassParameters
    case requiredParametersNotSupplied
    case unableToParseCallResult
    case functionError(String)
    //    case unableToPassParameters = "Unable to pass the parameters to the function"
    //    case requiredParametersNotSupplied = "Required parameters not supplied"
    //    case unableToParseCallResult = "Unable to parse call result"
    
    public var errorDescription: String? {
        switch self {
        case .unableToPassParameters:
            "Unable to pass the parameters to the function"
        case .requiredParametersNotSupplied:
            "Required parameters not supplied"
        case .unableToParseCallResult:
            "Unable to parse call result"
        case .functionError(let message):
            message
        }
    }
}

extension String {
    func toJsonObject() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
}

extension Dictionary where Key == String, Value: Encodable {
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

extension Dictionary where Key == String {
    func param(_ key: String) -> String? {
        if let value = self[key] {
            if let strValue = value as? String {
                return strValue
            } else {
                return "\(value)"
            }
        }
        return nil
    }
}

extension Encodable {
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(self) else {
            return nil
        }
        return String(data: jsonData, encoding: .utf8)
    }
}

open class OpenAIChatProvider: ChatProvider {
    let openAI: OpenAI
    let temperature: OpenAIChatTemperature
    let model: String       // e.g. "gpt-3.5-turbo"
    let maxTokens: Int?
    let userID: String?
    let functions: [OpenAIFunction]?
    
    public init(openAI: OpenAI, temperature: OpenAIChatTemperature = .creativeWriting, model: String = "gpt-3.5-turbo", maxTokens: Int? = nil, userID: String? = nil, functions: [OpenAIFunction]? = nil) {
        self.openAI = openAI
        self.temperature = temperature
        self.model = model
        self.maxTokens = maxTokens
        self.userID = userID
        self.functions = functions
    }
    
    open func performChat(withMessages messages: [any Message]) async throws -> any Message {
        guard let messages = messages as? [OpenAIMessage] else {
            fatalError("Messages are not of type OpenAIMessage")
        }
        
        let chats = messages.map { $0.chat }
        
        let query = ChatQuery(
            model: model,
            messages: chats,
            functions: functions?.map { $0.chatFunctionDeclaration },
            functionCall: nil,
            temperature: temperature.temperature,
            maxTokens: maxTokens,
            user: userID
        )
        
        do {
            // Perform the actual OpenAI chat
            let result = try await openAI.chats(query: query)
            
            // Get the first choice from the response
            guard let firstChoice = result.choices.first else {
                throw OpenAIChatProviderError.invalidResponse
            }
            
            switch firstChoice.finishReason {
            case "length":
                throw OpenAIChatProviderError.maxTokensExceeded
            case "content_filter":
                throw OpenAIChatProviderError.contentFilterException
            case "function_call":
                return try await handleFunctionCall(firstChoice.message)
            default:
                return OpenAIMessage(chat: firstChoice.message)
            }
        } catch {
            // Propagate the error to the caller.
            throw error
        }
    }
    
    private func handleFunctionCall(_ message: Chat) async throws -> OpenAIMessage {
        guard let functionName = message.functionCall?.name else {
            throw OpenAIChatProviderError.noFunctionNameSpecified
        }
        
        guard let arguments = message.functionCall?.arguments else {
            throw OpenAIChatProviderError.noArgumentsSpecified
        }
        
        guard let functions = self.functions else {
            throw OpenAIChatProviderError.noFunctionMatch(functionName)
        }
        
        let function = try getFunction(from: functions, for: functionName)
        
        var result: String
        do {
            let functionResult = try await execute(function, with: arguments)
            
            result = functionResult.jsonString ?? ["status": "success"].jsonString!
        } catch {
            result = ["status": "failed", "error": error.localizedDescription].jsonString!
        }
        let chat = Chat(role: .function, content: result, name: functionName)
        return OpenAIMessage(chat: chat)
    }
    
    private func getFunction(from functions: [OpenAIFunction], for name: String) throws -> OpenAIFunction {
        let functionMap = functions.reduce(into: [String: OpenAIFunction]()) { (result, function) in
            result[function.chatFunctionDeclaration.name] = function
        }
        
        guard let function = functionMap[name] else {
            throw OpenAIChatProviderError.noFunctionMatch(name)
        }
        return function
    }
    
    private func execute(_ function: OpenAIFunction, with arguments: String) async throws -> Encodable {
        guard let jsonObject = arguments.toJsonObject() else {
            throw FunctionCallError.unableToPassParameters
        }
        
        if let requiredParams = function.chatFunctionDeclaration.parameters.required,
           requiredParams.count > 0 && requiredParams.filter({ jsonObject.param($0) == nil }).count > 0 {
            throw FunctionCallError.requiredParametersNotSupplied
        }
        
        do {
            return try await function.call(parameters: jsonObject)
        } catch {
            throw FunctionCallError.functionError(error.localizedDescription)
        }
    }
}

