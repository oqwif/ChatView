//
//  ChatViewModelTests.swift
//  
//
//  Created by Jim Conroy on 25/9/2023.
//

import XCTest
@testable import ChatView

class MockChatProvider: ChatProvider {
    var shouldReturnError = false
    
    func performChat(withMessages messages: [Message]) async throws -> Message {
        if shouldReturnError {
            throw NSError(domain: "MockChatProvider", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        }
        
        // Return a mock message
        return Message(text: "Mock Message", role: .assistant)
    }
}

class ChatViewModelTests: XCTestCase {
    
    var sut: ChatViewModel! // system under test
    var mockChatProvider: MockChatProvider!
    
    override func setUp() {
        super.setUp()
        mockChatProvider = MockChatProvider()
        sut = ChatViewModel(systemPrompt: "Test", chatProvider: mockChatProvider)
    }
    
    override func tearDown() {
        sut = nil
        mockChatProvider = nil
        super.tearDown()
    }
    
    func testSendMessage() {
        // Arrange
        sut.newMessage = "Hello, Test!"
        
        // Act
        sut.sendMessage()
        
        // Assert
        // Verify if the new message is added to the messages array and if it's a user's message.
        XCTAssertEqual(sut.messages.last?.text, "Hello, Test!")
        XCTAssertEqual(sut.messages.last?.role, .user)
        XCTAssertEqual(sut.newMessage, "")
    }
    
    func testRetry() async {
        // Arrange
        let message = Message(text: "Error Message", role: .assistant, isError: true)
        sut.messages.append(message)
        
        // Act
        sut.retry()
        
        // Assert
        // Check if the error message is removed from the messages array.
        XCTAssertFalse(sut.messages.contains { $0.isError })
    }
    
    // And similarly other tests based on your other public methods and properties of your ViewModel.
}
