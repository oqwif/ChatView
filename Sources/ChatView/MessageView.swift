//
//  MessageView.swift
//
//  Created by Jim Conroy on 1/9/2023.
//

import SwiftUI

struct MessageView: View {
    var message: Message
    var retryAction: (() -> Void)? // Retry action closure
    
    @ViewBuilder
    var messageContent: some View {
        if message.isReceiving {
            AnimatedEllipsisView()
        } else if message.isError {
            VStack {
                Text(message.text)
                Button(action: {
                    retryAction?() // Call the retry action closure
                }) {
                    Text("Retry")
                }
            }
        } else {
            Text(message.text)
        }
    }
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                messageContent
                    .padding(.all, 8.0)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                messageContent
                    .padding(.all, 8.0)
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding([.leading, .trailing, .top], 8.0)
    }
}

struct AnimatedEllipsisView: View {
    @State private var visibleDots = 0

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 4, height: 4)
                    .opacity(visibleDots > index ? 1 : 0)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                visibleDots = (visibleDots + 1) % 4
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: Message.sampleMessages[0])
    }
}
