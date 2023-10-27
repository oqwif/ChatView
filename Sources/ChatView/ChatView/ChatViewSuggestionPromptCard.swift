//
//  SwiftUIView.swift
//  
//
//  Created by Jim Conroy on 27/10/2023.
//

import SwiftUI

public struct ChatViewSuggestionPrompt: Identifiable {
    public let id: UUID = UUID()
    public let title: String
    public let body: String
    public let prompt: String
    
    public init(title: String, body: String, prompt: String? = nil) {
        self.title = title
        self.body = body
        self.prompt = prompt ?? "\(title) \(body)"
    }
}

struct ChatViewSuggestionPromptCard: View {
    let prompt: ChatViewSuggestionPrompt
    let theme: ChatTheme
    
    init(prompt: ChatViewSuggestionPrompt, theme: ChatTheme = ChatTheme()) {
        self.prompt = prompt
        self.theme = theme
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(prompt.title)
                .font(theme.characterMessageFont)
            Text(prompt.body)
                .font(theme.characterMessageFont)
                .foregroundColor(.gray)
        }
        .padding(.all, 12.0)
        .background(theme.userMessageBackgroundColor)
        .cornerRadius(15)
    }
}

#Preview {
    ChatViewSuggestionPromptCard(
    prompt: ChatViewSuggestionPrompt(
        title: "What are the top three tasks",
        body: "that I should focus on?",
        prompt: "What are the top three tasks that I should focus on?"))
}
