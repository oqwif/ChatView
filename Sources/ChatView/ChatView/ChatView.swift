//
//  ChatView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

public struct ChatView<MessageType: Message, MessageView: MessageViewProtocol>: View {
    @StateObject private var viewModel: ChatViewModel<MessageType>
    public let theme: ChatTheme
    
    @State private var showErrorAlert = false
    
    public init(viewModel: ChatViewModel<MessageType>, theme: ChatTheme? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme ?? ChatTheme()
    }
    
    public var body: some View {
        ZStack {
            VStack {
                chatList
                messageInputField
            }
            .blur(radius: viewModel.isMessageViewTapped ? 5.0 : 0)
        }
        .task {
            await viewModel.startChat()
        }
        .alert(isPresented: $showErrorAlert) {
            errorAlert
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
    
    private var messageInputField: some View {
        HStack {
            TextField("Send a message", text: $viewModel.newMessage, onCommit: {
                viewModel.sendMessage()
            })
            .textFieldStyle(.roundedBorder)
            .lineLimit(5)
            
            sendButton
        }
        .padding()
    }

    
    private var sendButton: some View {
        Button(action: viewModel.sendMessage) {
            Image(systemName: "paperplane.fill")
        }
    }
    
    private var errorAlert: Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.errorMessage ?? "Unknown error"),
            dismissButton: .default(Text("OK"))
        )
    }
    
    private func scrollToLastMessage(in proxy: ScrollViewProxy) {
        withAnimation {
            if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

class MockChatProvider: ChatProvider<MockMessage> {
    override func performChat(withMessages messages: [MockMessage]) async throws -> MockMessage {
        return MockMessage(text: "Assistant response", role: MessageRole.assistant)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let mockMessages = MockMessage.sampleMessages
        let viewModel = ChatViewModel<MockMessage>(chatProvider: MockChatProvider(),
                                      messages: mockMessages) // Pass sample messages here

        ChatView<MockMessage, ChatMessageView>(viewModel: viewModel)
    }
}
