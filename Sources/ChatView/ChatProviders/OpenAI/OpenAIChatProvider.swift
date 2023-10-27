//
//  File.swift
//
//
//  Created by Jamie Conroy on 25/9/2023.
//

import Foundation
import OpenAI


/**
 `OpenAIChatProviderError` is an enum that represents errors that can occur in the `OpenAIChatProvider`. It conforms to the `LocalizedError` protocol to provide localized error descriptions.

 The enum contains several cases:
 - `invalidResponse`: Represents an error where an invalid response was received from the API.
 - `maxTokensExceeded`: Represents an error where the maximum number of tokens specified in the request was reached.
 - `contentFilterException`: Represents an error where content was omitted due to a flag from API content filters.
 - `noResponseMessageContent`: Represents an error where no content was received in the message returned from the API.
 - `noFunctionNameSpecified`: Represents an error where the API tried to call a function but no name was specified.
 - `noArgumentsSpecified`: Represents an error where the API tried to call a function but no arguments were specified.
 - `noFunctionMatch(String)`: Represents an error where the API tried to call an unmatched function. The associated value is the name of the unmatched function.
 - `other(String)`: A generic error type for other unforeseen errors. The associated value is the error message.

 The enum provides a `errorDescription` computed property that returns a localized description of the error.
 */
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

/**
 `FunctionCallError` is an enum that represents errors that can occur when calling a function in the `OpenAIChatProvider`. It conforms to the `LocalizedError` protocol to provide localized error descriptions.

 The enum contains several cases:
 - `unableToPassParameters`: Represents an error where the function was unable to pass parameters.
 - `requiredParametersNotSupplied`: Represents an error where required parameters were not supplied to the function.
 - `unableToParseCallResult`: Represents an error where the function was unable to parse the result of a call.
 - `functionError(String)`: Represents an error that occurred within the function itself. The associated value is the error message.

 The enum provides a `errorDescription` computed property that returns a localized description of the error.
 */
public enum FunctionCallError: LocalizedError {
    case unableToPassParameters
    case requiredParametersNotSupplied
    case unableToParseCallResult
    case functionError(String)
    
    public var errorDescription: String? {
        switch self {
        case .unableToPassParameters:
            return "Unable to pass the parameters to the function"
        case .requiredParametersNotSupplied:
            return "Required parameters not supplied"
        case .unableToParseCallResult:
            return "Unable to parse call result"
        case .functionError(let message):
            return message
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

/**
 `OpenAIChatProvider` is a class that extends `ChatProvider` and provides an implementation for performing a chat using the OpenAI API. It uses `OpenAIMessage` as its message type.

 The class contains several properties:
 - `openAI`: An instance of `OpenAI` that is used to interact with the OpenAI API.
 - `temperature`: The temperature setting for the OpenAI API.
 - `model`: The model to be used for the chat.
 - `maxTokens`: The maximum number of tokens that the chat can use.
 - `userID`: The user ID for the chat.
 - `functions`: An array of `OpenAIFunction` that can be called during the chat.
 - `systemMessageProvider`: Use one of these if you would like to update the system message before every call to OpenAI. Useful for inserting the time, date, etc.

 The class provides an initializer that allows all of these properties to be set.

 The class overrides the `performChat(withMessages:)` method to perform a chat using the OpenAI API. It also provides several private methods for handling function calls and executing functions.

 The class also contains several extensions for `String`, `Dictionary`, and `Encodable` to facilitate the conversion between JSON and Swift types.

 The `OpenAIChatProviderError` enum is used to define errors that can occur in the `OpenAIChatProvider`.

 The `FunctionCallError` enum is used to define errors that can occur when calling a function.
 */
open class OpenAIChatProvider: ChatProvider<OpenAIMessage> {
    let openAI: OpenAI
    let temperature: OpenAIChatTemperature
    let model: String       // e.g. "gpt-3.5-turbo"
    let maxTokens: Int?
    let userID: String?
    let functions: [OpenAIFunction]?
    let systemMessageProvider: OpenAISystemMessageProvider?
    
    public init(
        openAI: OpenAI,
        temperature: OpenAIChatTemperature = .chatbotResponses,
        model: String = "gpt-3.5-turbo",
        maxTokens: Int? = nil,
        userID: String? = nil,
        functions: [OpenAIFunction]? = nil,
        systemMessageProvider: OpenAISystemMessageProvider? = nil
    ) {
        self.openAI = openAI
        self.temperature = temperature
        self.model = model
        self.maxTokens = maxTokens
        self.userID = userID
        self.functions = functions
        self.systemMessageProvider = systemMessageProvider
    }
    
    open override func performChat(withMessages messages: [OpenAIMessage]) async throws -> OpenAIMessage {
        let messages = updateSystemMessage(withMessages: messages)
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
                guard let functionCall = firstChoice.message.functionCall else {
                    throw OpenAIChatProviderError.noFunctionNameSpecified
                }
                guard let functionName = functionCall.name else {
                    throw OpenAIChatProviderError.noFunctionNameSpecified
                }

                guard let functionArguments = functionCall.arguments else {
                    throw OpenAIChatProviderError.noArgumentsSpecified
                }
                
                return try await handleFunctionCall(functionName, arguments: functionArguments)
            default:
                return OpenAIMessage(chat: firstChoice.message)
            }
        } catch {
            // Propagate the error to the caller.
            throw error
        }
    }
    
    open override func performStreamChat(withMessages messages: [OpenAIMessage]) -> AsyncThrowingStream<OpenAIMessage, Error> {
        let messages = updateSystemMessage(withMessages: messages)
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
        return AsyncThrowingStream { continuation in
            // Set up a Task to handle the stream
            Task {
                do {
                    let id = UUID()
                    var text = ""
                    var functionName: String?
                    var functionArguments: String?
                    
                    // Iterate over the values in the stream
                    for try await result in self.openAI.chatsStream(query: query) {
                        // Convert each ChatStreamResult to MessageType
                        // Get the first choice from the response
                        if let firstChoice = result.choices.first {
                            if let finishReason = firstChoice.finishReason {
                                switch finishReason {
                                case "length":
                                    throw OpenAIChatProviderError.maxTokensExceeded
                                case "content_filter":
                                    throw OpenAIChatProviderError.contentFilterException
                                case "function_call":
                                    guard let functionName = functionName else {
                                        throw OpenAIChatProviderError.noFunctionNameSpecified
                                    }

                                    guard let functionArguments = functionArguments else {
                                        throw OpenAIChatProviderError.noArgumentsSpecified
                                    }

                                    let message = try await handleFunctionCall(functionName, arguments: functionArguments)
                                    continuation.yield(message)
                                    
                                    break
                                default:
                                    break
                                }
                            } else {
                                let delta = firstChoice.delta
                                
                                if let functionCall = firstChoice.delta.functionCall {
                                    if let name = functionCall.name {
                                        functionName = name
                                    }
                                    if let arguments = functionCall.arguments {
                                        functionArguments = arguments
                                    }
                                } else {
                                    guard let content = delta.content else {
                                        throw OpenAIChatProviderError.noResponseMessageContent
                                    }
                                    text += content
                                    
                                    continuation.yield(
                                        OpenAIMessage(
                                            id: id,
                                            text: text,
                                            role: .assistant,
                                            isReceiving: false
                                        )
                                    )
                                }
                            }
                        }
                    }
                    // If the loop exits normally, finish the continuation
                    continuation.finish()
                } catch {
                    // If an error is thrown, finish the continuation with the error
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func updateSystemMessage(withMessages messages: [OpenAIMessage]) -> [OpenAIMessage] {
        guard let systemMessageProvider = systemMessageProvider else {
            return messages
        }
        let newSystemMessage = OpenAIMessage(text: systemMessageProvider.systemMessage, role: .system)
        var newMessages = messages
        
        if let systemMessage = messages.first, systemMessage.role == .system {
            newMessages = Array(newMessages.dropFirst())
        }
        newMessages.insert(newSystemMessage, at: 0)

        return newMessages
    }
    
    private func handleFunctionCall(_ functionName: String, arguments: String) async throws -> OpenAIMessage {
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
        let jsonObject = arguments.toJsonObject() ?? [:]
        
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

