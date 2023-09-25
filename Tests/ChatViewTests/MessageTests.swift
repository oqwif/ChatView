import XCTest
@testable import ChatView

class MessageTests: XCTestCase {
    
    func testMessageInitialization() {
        let message = Message(text: "Hello!", isUser: true)
        
        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.text, "Hello!")
        XCTAssertTrue(message.isUser)
        XCTAssertFalse(message.isReceiving)
        XCTAssertFalse(message.isError)
    }
    
    func testMessageCopyWith() {
        let message = Message(text: "Hello!", isUser: true)
        let copiedMessage = message.copyWith(text: "Hello, World!")
        
        XCTAssertEqual(copiedMessage.text, "Hello, World!")
        XCTAssertTrue(copiedMessage.isUser)
        XCTAssertFalse(copiedMessage.isReceiving)
        XCTAssertFalse(copiedMessage.isError)
    }
}
