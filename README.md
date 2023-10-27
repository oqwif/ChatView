# ChatView Swift Package
---
![Swift Workflow](https://github.com/oqwif/ChatView/actions/workflows/swift.yml/badge.svg)
---
`ChatView` is a robust and customizable SwiftUI package, facilitating the implementation of a sleek and user-friendly SwiftUI chat view with support for custom themes and the OpenAI chat API. 

## Installation

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/oqwif/ChatView.git", from: "1.1.1")
```

Rather than rewrite all the OpenAI integration, ChatView depends on the awesome [MacPaw OpenAI](https://github.com/MacPaw/OpenAI) package. Xcode will add the dependency when ChatView is added.

## Components

`ChatView` is the main SwiftUI view that provides a chat interface. It displays a list of messages and a text field for inputting new messages. The view uses generics to allow for different types of messages and message views, provided they conform to the `Message` and `MessageViewProtocol` protocols respectively.

There are a couple of useful typealiases, `OpenAIChatView` and `OpenAIChatViewModel` specifcally for instantiating an OpenAIChatView. See the example below in Basic Usage.

`ChatMessageView` is a SwiftUI view that displays a chat message. It supports different types of messages (receiving, error, normal) and different roles (user, character). It also provides a retry button for error messages and a context menu for copying the message text.

`ChatTheme` is a struct that encapsulates the appearance settings for a `ChatView`. It provides a way to customize the look and feel of the chat interface.

`OpenAIChatProvider` is a class that extends `ChatProvider` and provides an implementation for performing a chat using the OpenAI API. It uses `OpenAIMessage` as its message type.

## Basic Usage

Here is a quick example of a ChatBot using the OpenAI API. Start a new Xcode project and replace the ContentView with the following. Fire up the project, enter your API key and enjoy your brief adventure with Isaac A!

```swift
import SwiftUI
import ChatView
import OpenAI

struct ContentView: View {
    @State private var showingAlert = true
    @State private var apiKey = ""
    
    private let systemPrompt = """
Imagine that you are Isaac Asimov. Start by introducing yourself and asking the user if they would like to do a short "choose your own" space adventure.
"""
    
    var body: some View {
        if !apiKey.isEmpty {
            OpenAIChatView(
                viewModel: OpenAIChatViewModel(
                    chatProvider: OpenAIChatProvider(openAI: OpenAI(apiToken: apiKey)),
                    messages: [OpenAIMessage(text: systemPrompt, role: .system)]
                ))
        } else {
            Text("")
                .alert("Enter your OpenAI API key", isPresented: $showingAlert) {
                    TextField("API Key", text: $apiKey)
                    Button("OK", action: {})
                } message: {
                    Text("")
                }
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

