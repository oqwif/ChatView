//
//  ChatView.swift
//  This file contains the ChatView struct, which is a SwiftUI view for a chat interface.
//  It also contains the MockChatProvider class, which is a mock provider for chat messages.
//
//  Created by Jamie Conroy on 1/9/2023.
//

import SwiftUI


/**
 `ChatView` is a SwiftUI view that provides a chat interface. It displays a list of messages and a text field for inputting new messages. The view uses generics to allow for different types of messages and message views, provided they conform to the `Message` and `MessageViewProtocol` protocols respectively.

 The view contains several properties:
 - `viewModel`: An instance of `ChatViewModel` that acts as the view model for this view.
 - `theme`: An instance of `ChatTheme` that determines the appearance of the chat interface.
 - `showErrorAlert`: A boolean state variable that determines whether an error alert should be shown.

  */
public struct ChatView<MessageType: Message, MessageView: MessageViewProtocol>: View {
    // The view model for this chat view.
    @StateObject private var viewModel: ChatViewModel<MessageType>
    
    // The theme for this chat view.
    public let theme: ChatTheme
    
    public let suggestionPrompts: [ChatViewSuggestionPrompt]?

    @State private var showErrorAlert = false
    @FocusState private var isInputFieldFocused: Bool
    
    /// Initializes a new chat view with the given view model and theme.
    public init(viewModel: ChatViewModel<MessageType>, 
                theme: ChatTheme? = nil,
                suggestionPrompts: [ChatViewSuggestionPrompt]? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme ?? ChatTheme()
        self.suggestionPrompts = suggestionPrompts
    }
    
    public var body: some View {
        ZStack {
            VStack {
                chatList
                if(self.suggestionPrompts != nil && !viewModel.chatStarted && viewModel.newMessage.isEmpty) {
                    withAnimation {
                        suggestionPromptsView
                    }
                }
                messageInputField
            }
            .gesture(
                DragGesture().onChanged { value in
                    if value.translation.height > 0 {
                        isInputFieldFocused = false
                    }
                }
            )
            .blur(radius: viewModel.isMessageViewTapped ? 5.0 : 0)
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.errorMessage) { newValue in
            showErrorAlert = newValue != nil
        }
    }
    
    private var chatList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(viewModel.messages.filter { $0.role != .system && $0.isHidden == false}) { message in
                    MessageView(message: message, theme: theme, retryAction: viewModel.retry)
                        .id(message.id)
                }
            }
            .onChange(of: viewModel.messages) { _ in
                scrollToLastMessage(in: proxy)
            }
        }
    }
    
    private var suggestionPromptsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestionPrompts ?? []) { prompt in
                    ChatViewSuggestionPromptCard(prompt: prompt, theme: theme)
                        .onTapGesture {
                            // Handle the tap here
                            // You can call a method and pass the prompt as a parameter
                            handleSuggestionPromptTap(prompt: prompt.prompt)
                        }
                } 
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 5)
    }
    
    private func handleSuggestionPromptTap(prompt: String) {
        viewModel.newMessage = prompt
        viewModel.sendMessage()
    }
    
    private var messageInputField: some View {
        HStack {
            TextField("Send a message", text: $viewModel.newMessage, axis: .vertical)
            .onSubmit {
                viewModel.sendMessage()
            }
            .textFieldStyle(.roundedBorder)
            .focused($isInputFieldFocused)
            .lineLimit(5)
            .onChange(of: viewModel.shouldFocusTextField) { shouldFocus in
                if shouldFocus {
                    isInputFieldFocused = true
                    viewModel.clearFocusRequest() // Reset the request
                }
            }
            
            sendButton
        }
        .padding()
    }

    
    private var sendButton: some View {
        Button(action: viewModel.sendMessage) {
            Image(systemName: "paperplane.fill")
        }
    }
    
    private func scrollToLastMessage(in proxy: ScrollViewProxy) {
        // Use the debouncer to delay the scroll to end action
        DispatchQueue.main.async {
            if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}



/// A mock provider for chat messages. This class is used for testing purposes.
class MockChatProvider: ChatProvider<MockMessage> {
    /// Performs a chat with the given messages and returns a mock response.
    override func performChat(withMessages messages: [MockMessage]) async throws -> [MockMessage] {
        return [MockMessage(text: "Assistant response", role: MessageRole.assistant)]
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMessages = MockMessage.sampleMessages
        let viewModel = ChatViewModel<MockMessage>(chatProvider: MockChatProvider(),
                                      messages: mockMessages) // Pass sample messages here

        ChatView<MockMessage, ChatMessageView>(
            viewModel: viewModel,
            suggestionPrompts: [ChatViewSuggestionPrompt(
                title: "What are the top three tasks",
                body: "that I should focus on?",
                prompt: "What are the top three tasks that I should focus on?")]
        )
    }
}
