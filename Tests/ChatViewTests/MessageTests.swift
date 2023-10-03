import XCTest
@testable import ChatView

class MessageTests: XCTestCase {
    
    func testMessageInitialization() {
        let message = MockMessage(text: "Hello!", role: .user)
        
        XCTAssertNotNil(message.id)
        XCTAssertEqual(message.text, "Hello!")
        XCTAssertEqual(message.role, .user)
        XCTAssertFalse(message.isReceiving)
        XCTAssertFalse(message.isError)
    }
    
    func testMessageCopyWith() {
        let message = MockMessage(text: "Hello!", role: .user)
        let copiedMessage = message.copyWith(text: "Hello, World!")
        
        XCTAssertEqual(copiedMessage.text, "Hello, World!")
        XCTAssertEqual(copiedMessage.role, .user)
        XCTAssertFalse(copiedMessage.isReceiving)
        XCTAssertFalse(copiedMessage.isError)
    }
}
