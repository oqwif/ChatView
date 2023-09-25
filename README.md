# ChatView Swift Package
`ChatView` is a robust and customizable SwiftUI package, facilitating the implementation of a sleek and user-friendly chat UI with support for custom themes, response triggers, and diverse chat providers including OpenAI. The package also comes with ready-made error handling and retry mechanisms, making the integration process seamless.

## Installation

Add the following dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/oqwif/ChatView", from: "1.0.12")
```

## Components
- `ChatView`: The main view component representing the chat interface.
- `ChatViewModel`: The ViewModel associated with `ChatView` managing the chat logic.
- `ChatTheme`: Allows customization of visual elements in the chat.
- `ChatProvider`: A protocol representing a chat message provider.
- `OpenAIChatProvider`: A conformer to `ChatProvider` which integrates OpenAI.
- `ChatResponseTrigger`: A protocol representing actions that can be triggered based on chat responses.

## Basic Usage

### Initialize ViewModel
```swift
import ChatView
let viewModel = ChatViewModel(chatProvider: YourChatProvider())
```

### Presenting ChatView
```swift
ChatView(viewModel: viewModel)
```

## Customizing Chat Theme

```swift
let theme = ChatTheme(
    userMessageBackgroundColor: Color.blue,
    characterMessageBackgroundColor: Color.purple,
    userMessageFont: .custom("Comic Sans MS", size: 16),
    // ... other properties ...
)

ChatView(viewModel: viewModel, theme: theme)
```

## Chat Response Triggers

Implement the `ChatResponseTrigger` protocol to create custom triggers based on chat responses:

```swift
struct CustomTrigger: ChatResponseTrigger {
    func shouldActivate(forChatResponse response: String) -> Bool {
        // Your logic here
    }
    
    func activate() {
        // Action to perform when activated
    }
}
```

Pass it to the ViewModel like so:

```swift
let viewModel = ChatViewModel(chatProvider: YourChatProvider(), triggers: [CustomTrigger()])
```

## OpenAI Integration

For integrating OpenAI as a chat provider, initialize `OpenAIChatProvider` and pass it to the ViewModel.

```swift
let openAIProvider = OpenAIChatProvider(openAI: YourOpenAIInstance, model: "gpt-3.5-turbo")
let viewModel = ChatViewModel(chatProvider: openAIProvider)
```

## Advanced Usage

For advanced scenarios like custom message views and animations, please refer to the package documentation and examples provided in the code.

## Requirements
- iOS 15.0+ / macOS 11.0+
- Xcode 13.0+
- Swift 5.5+

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributions
We welcome contributions, enhancements, and bug-fixes. Feel free to open an issue or create a pull request.

## Acknowledgements
Created by Jim Conroy on 22/9/2023.

This README is a quick start guide. For detailed documentation on each component and protocol, please refer to the inline documentation provided in each Swift file within the package.

## Disclaimer
Ensure to review and comply with OpenAI's use case policy when using OpenAIChatProvider, especially when deploying in production.

