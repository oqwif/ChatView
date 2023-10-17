//
//  ContentView.swift
//  AdventureChatView
//
//  Created by Jim Conroy on 17/10/2023.
//

import SwiftUI
import ChatView
import OpenAI

public typealias OpenAIChatViewModel = ChatViewModel<OpenAIMessage>

struct ContentView: View {
    @State private var showingAlert = true
    @State private var apiKey = ""
    
    private let systemPrompt = """
Imagine that you are Isaac Asimov. Start by introducing yourself and asking the user if they would like to do a short "choose your own" space oddessey adventure.
"""
    
    var body: some View {
        if !apiKey.isEmpty {
            OpenAIChatView(
                viewModel: OpenAIChatViewModel(
                    chatProvider: OpenAIChatProvider(openAI: OpenAI(apiToken: apiKey)),
                    messages: [OpenAIMessage(text: systemPrompt, role: .system)]
                ))
        } else {
            Text("")
                .alert("Enter your OpenAI API key", isPresented: $showingAlert) {
                    TextField("API Key", text: $apiKey)
                    Button("OK", action: {})
                } message: {
                    Text("")
                }
        }
    }
}


#Preview {
    ContentView()
}
