//
//  MessageView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

struct MessageView: View {
    var message: Message
    var theme: ChatTheme
    var retryAction: (() -> Void)? // Retry action closure
    
    @ViewBuilder
    var messageContent: some View {
        if message.isReceiving {
            AnimatedEllipsisView(color: theme.animatedEllipsisColor, size: theme.animatedEllipsisSize)
        } else if message.isError {
            VStack {
                Text(message.text)
                    .font(theme.errorMessageFont)
                Button(action: {
                    retryAction?() // Call the retry action closure
                }) {
                    Text("Retry")
                        .font(theme.retryButtonFont)
                        .padding(4)
                        .background(theme.retryButtonBackgroundColor)
                        .foregroundColor(theme.retryButtonTextColor)
                        .cornerRadius(4)
                }
            }
        } else {
            Text(message.text)
                .font(message.role == .user ? theme.userMessageFont : theme.characterMessageFont)
                .foregroundColor(message.role == .user ? theme.userMessageTextColor : theme.characterMessageTextColor)
        }
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                messageContent
                    .padding(.all, 12.0)
                    .background(theme.userMessageBackgroundColor)
                    .cornerRadius(15)
            } else {
                messageContent
                    .padding(.all, 12.0)
                    .background(theme.characterMessageBackgroundColor)
                    .cornerRadius(15)
                Spacer()
            }
        }
        .padding([.leading, .trailing, .top], 12.0)
    }
}

struct AnimatedEllipsisView: View {
    var color: Color
    var size: CGFloat
    @State private var visibleDots = 0

    var body: some View {
        HStack(spacing: size / 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(color)
                    .opacity(visibleDots > index ? 1 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                visibleDots = (visibleDots + 1) % 4
            }
        }
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
            ForEach(Message.sampleMessages) { message in
                MessageView(message: message, theme: theme, retryAction: nil)
            }
        }
        
        VStack {
            ForEach(Message.sampleMessages) { message in
                MessageView(message: message, theme: ChatTheme(), retryAction: nil)
            }
        }
    }
}
