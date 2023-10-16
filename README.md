# ChatView Swift Package
`ChatView` is a robust and customizable SwiftUI package, facilitating the implementation of a sleek and user-friendly SwiftUI chat view with support for custom themes and the OpenAI chat API. 

## Installation

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/oqwif/ChatView", from: "1.1.0")
```

## Components

`ChatView` is the main SwiftUI view that provides a chat interface. It displays a list of messages and a text field for inputting new messages. The view uses generics to allow for different types of messages and message views, provided they conform to the `Message` and `MessageViewProtocol` protocols respectively.

`ChatMessageView` is a SwiftUI view that displays a chat message. It supports different types of messages (receiving, error, normal) and different roles (user, character). It also provides a retry button for error messages and a context menu for copying the message text.

`ChatTheme` is a struct that encapsulates the appearance settings for a `ChatView`. It provides a way to customize the look and feel of the chat interface.

`OpenAIChatProvider` is a class that extends `ChatProvider` and provides an implementation for performing a chat using the OpenAI API. It uses `OpenAIMessage` as its message type.

## Basic Usage

Here is a quick example of a ChatBot using the OpenAI API

```swift
import SwiftUI
import ChatView
import OpenAI

class MyChatProvider: OpenAIChatProvider {
    
    static let systemPrompt = """
Imagine that you are Isaac Asimov. Start by introducing yourself and asking the user if they would like to do a short "choose your own" adventure.
"""
    
    static public func getSystemMessage() async -> String {
        return systemPrompt
    }
}

struct AdventureChatView: View {
    var chatViewModel: ChatViewModel<OpenAIMessage> {
        let systemPrompt = MyChatProvider.systemPrompt    
        let token = OpenAI(apiToken: "YOUR_TOKEN_HERE")    // Note: do not store your API token in code. This is an example only.
        let chatProvider = AdventureChatProvider(
            openAI: OpenAI(apiToken: token),
            temperature: .chatbotResponses,
            model: model,
            maxTokens: 700,
            functions: [
                SendMessageToDeveloperFunction()
            ]
        )
        return ChatViewModel<OpenAIMessage>(
            chatProvider: chatProvider, messages: [OpenAIMessage(text: systemPrompt, role: .system)])
    }
    
    var body: some View {
        OpenAIChatView(viewModel: chatViewModel)
    }
}

@main
struct AdventureChatApp: App {
    var body: some Scene {
        WindowGroup {
            AdventureChatView()
        }
    }
}

```


## Advanced Usage

For advanced scenarios like custom message views and animations, please refer to the package documentation and examples provided in the code.

For example, you can customize the appearance of the chat interface by creating an instance of `ChatTheme` and passing it to `ChatView`'s initializer:

```swift
let theme = ChatTheme(
    userMessageBackgroundColor: Color.blue,
    characterMessageBackgroundColor: Color.purple,
    userMessageFont: .custom("Comic Sans MS", size: 16),
    characterMessageFont: .custom("Comic Sans MS", size: 16),
    userMessageTextColor: .white,
    characterMessageTextColor: .white
)
let viewModel = ChatViewModel<MockMessage>(chatProvider: MockChatProvider(), messages: mockMessages)
ChatView<MockMessage, ChatMessageView>(viewModel: viewModel, theme: theme)
```

You can also use `OpenAIChatProvider` to perform a chat using the OpenAI API:

```swift
let openAI = OpenAI(apiKey: "your-api-key")
let openAIChatProvider = OpenAIChatProvider(openAI: openAI)
let viewModel = ChatViewModel<OpenAIMessage>(chatProvider: openAIChatProvider)
OpenAIChatView(viewModel: viewModel)
```

## Requirements
- iOS 16.0+ / macOS 13.0+

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributions
We welcome contributions, enhancements, and bug-fixes. Feel free to open an issue or create a pull request.

## Acknowledgements
Created by Jamie Conroy on 22/9/2023.

This README is a quick start guide. For detailed documentation on each component and protocol, please refer to the inline documentation provided in each Swift file within the package.

## Disclaimer
Ensure to review and comply with OpenAI's use case policy when using OpenAIChatProvider, especially when deploying in production.

