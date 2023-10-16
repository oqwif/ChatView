//
//  MessageView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public protocol MessageViewProtocol: View {
    init(message: any Message, theme: ChatTheme, retryAction: (() -> Void)?)
}

public struct ChatMessageView: MessageViewProtocol {
    public var message: any Message
    public var theme: ChatTheme
    public var retryAction: (() -> Void)? // Retry action closure
    
    public init(message: any Message, theme: ChatTheme, retryAction: (() -> Void)?) {
        self.message = message
        self.theme = theme
        self.retryAction = retryAction
    }
    
    @ViewBuilder
    var messageContent: some View {
        switch messageType {
        case .receiving:
            AnimatedEllipsisView(color: theme.animatedEllipsisColor, size: theme.animatedEllipsisSize)
        case .error:
            errorContent
        case .normal(let role):
            normalContent(for: role)
        }
    }
    
    private var errorContent: some View {
        VStack {
            Text(message.text).font(theme.errorMessageFont)
            retryButton
        }
    }
    
    private var retryButton: some View {
        Button(action: {
            retryAction?()
        }) {
            Text("Retry")
                .font(theme.retryButtonFont)
                .padding(4)
                .background(theme.retryButtonBackgroundColor)
                .foregroundColor(theme.retryButtonTextColor)
                .cornerRadius(4)
        }
    }
    
    private func normalContent(for role: MessageRole) -> some View {
        Text(message.text)
            .font(role == .user ? theme.userMessageFont : theme.characterMessageFont)
            .foregroundColor(role == .user ? theme.userMessageTextColor : theme.characterMessageTextColor)
    }
    
    private enum MessageType {
        case receiving, error, normal(role: MessageRole)
    }
    
    private var messageType: MessageType {
        if message.isReceiving { return .receiving }
        if message.isError { return .error }
        return .normal(role: message.role)
    }
    
    private func copyTextToClipboard(text: String) {
#if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
#else
        UIPasteboard.general.string = text
#endif
    }
    
    public var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                messageContent
                    .padding(.all, 12.0)
                    .background(theme.userMessageBackgroundColor)
                    .cornerRadius(15)
                    .contextMenu {
                        Button(action: {
                            copyTextToClipboard(text: message.text)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
            } else {
                messageContent
                    .padding(.all, 12.0)
                    .background(theme.characterMessageBackgroundColor)
                    .cornerRadius(15)
                    .contextMenu {
                        Button(action: {
                            copyTextToClipboard(text: message.text)
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
                Spacer()
            }
        }
        .padding([.leading, .trailing, .top], 12.0)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        let theme = ChatTheme(
            userMessageBackgroundColor: Color.blue,
            characterMessageBackgroundColor: Color.purple,
            userMessageFont: .custom("Comic Sans MS", size: 16),
            characterMessageFont: .custom("Comic Sans MS", size: 16),
            userMessageTextColor: .white,
            characterMessageTextColor: .white,
            errorMessageFont: .custom("Comic Sans MS", size: 16),
            retryButtonFont: .custom("Comic Sans MS", size: 14),
            retryButtonBackgroundColor: Color.red,
            retryButtonTextColor: .white,
            animatedEllipsisColor: .yellow,
            animatedEllipsisSize: 8
        )
        
        VStack {
            ForEach(MockMessage.sampleMessages) { message in
                ChatMessageView(message: message, theme: theme, retryAction: nil)
            }
        }
        
        VStack {
            ForEach(MockMessage.sampleMessages) { message in
                ChatMessageView(message: message, theme: ChatTheme(), retryAction: nil)
            }
        }
    }
}
