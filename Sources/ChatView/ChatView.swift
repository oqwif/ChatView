//
//  ChatView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var showErrorAlert = false
    
    init(systemPrompt: String, token: String, userID: String? = nil) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            systemPrompt: systemPrompt,
            token: token,
            userID: userID,
            triggers: nil))
    }
    
    var body: some View {
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
                    MessageView(message: message, retryAction: viewModel.retry)
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

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(systemPrompt: "Imagine you are Benjamin Franklin, living during their respective time. Answer the users' questions in the manner and knowledge consistent with their time and persona. Start by introducing yourself.",
                 token: "12345")
    }
}
