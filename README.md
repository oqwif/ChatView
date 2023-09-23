# ChatView Swift Package README

## Description

ChatView is a Swift package for easily integrating chat functionality into your iOS applications. Built with SwiftUI, this package uses OpenAI's GPT for generating chat responses. It's highly customizable with various triggers and supports both system-generated prompts and user-defined queries. 

## Features

- Asynchronous API calls.
- Real-time chat experience.
- System-generated prompts for initial chat context.
- Automatic message scrolling.
- Error handling with retry mechanism.
- Optional triggers for specific chat responses.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/oqwif/ChatView.git", from: "1.0.0")
]
```

## Usage

### Import Package

First, import the package into the file where you want to use it:

```swift
import ChatView
```

### Initialize ChatView

You can initialize a `ChatView` instance like this:

```swift
ChatView(systemPrompt: "Your system prompt here", token: "Your OpenAI token", userID: "Optional user ID")
```

### Implementing Triggers

To implement triggers, you can define a class that conforms to `ChatResponseTrigger`. For example:

```swift
class MyTrigger: ChatResponseTrigger {
    func shouldActivate(forChatResponse response: String) -> Bool {
        return response.contains("trigger keyword")
    }
    
    func activate() {
        // Your activation code here.
    }
}
```

Add it to your `ChatViewModel`:

```swift
let triggers: [ChatResponseTrigger] = [MyTrigger()]
let viewModel = ChatViewModel(systemPrompt: "Your system prompt", token: "Your OpenAI token", userID: "Optional user ID", triggers: triggers)
```

## Customization

You can easily customize the chat UI and experience to fit your needs. The package is built in a modular way to allow easy modifications.

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+
  
## Contributing

If you find a bug or would like to suggest a new feature, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

Made with ❤️ by Jim Conroy. Feel free to reach out with any questions!
