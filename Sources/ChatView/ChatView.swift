//
//  ChatView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

public struct ChatView<Content: View>: View {
    @StateObject private var viewModel: ChatViewModel
    public let theme: ChatTheme
    
    @State private var showErrorAlert = false
    private let content: (Message, ChatTheme, (() -> Void)?) -> Content
    
    public init(viewModel: ChatViewModel, theme: ChatTheme? = nil, @ViewBuilder content: @escaping (Message, ChatTheme, (() -> Void)?) -> Content) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme ?? ChatTheme()
        self.content = content
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
                    content(message, theme, viewModel.retry)
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
            TextField("Send a message", text: $viewModel.newMessage, axis: .vertical)
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

class MockChatProvider: ChatProvider {
    func performChat(withMessages messages: [Message]) async throws -> Message {
        // Return a mock message
        Message(text: "Mock response", role: .assistant)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ChatViewModel(chatProvider: MockChatProvider(),
                                      messages: Message.sampleMessages) // Pass sample messages here
        return ChatView<MessageView>(viewModel: viewModel) { message, theme, retryAction in
            MessageView(message: message, theme: theme, retryAction: retryAction)
        }
    }
}
