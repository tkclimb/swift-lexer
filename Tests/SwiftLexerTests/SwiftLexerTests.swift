import XCTest
@testable import SwiftLexer

// struct Token {
//     let kind: TokenKind
//     let startIdx: Si
// }

enum TokenKind: String, Lexable {
    static var separators: Set<Character> = [" "]
    static var comment: String = "//"
    
    case text = "[A-Za-z]*"
    case number = "[0-9]*"
    
    case eof
    case none
}


final class SwiftLexerTests: XCTestCase {
    func testExample() {
        var lex = Lexer<TokenKind>()
        do {
            let tokens = try lex.run(input: "  H3Ll0 //  W0r 1d \n 1234 aBcD ")
            print(tokens)
        } catch let err {
            print(err)
        }
        XCTAssertEqual(0, 0)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
