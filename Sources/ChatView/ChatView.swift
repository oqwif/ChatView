//
//  ChatView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

public struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    public let theme: ChatTheme
    
    @State private var showErrorAlert = false
    
    public init(viewModel: ChatViewModel, theme: ChatTheme? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.theme = theme ?? ChatTheme()
    }
    
    public var body: some View {
        ZStack {
            VStack {
                chatList
                messageInputField
            }
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
                ForEach(viewModel.messages) { message in
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
            TextField("Enter message", text: $viewModel.newMessage)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5)
                .padding(.horizontal)
            
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
        Message(text: "Mock response", isUser: false)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ChatViewModel(systemPrompt: "Imagine you are Benjamin Franklin...",
                                      chatProvider: MockChatProvider(),
                                      messages: Message.sampleMessages) // Pass sample messages here
        return ChatView(viewModel: viewModel)
    }
}
