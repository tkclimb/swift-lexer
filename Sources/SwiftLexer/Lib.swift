import Foundation

public protocol Lexable: Hashable, RawRepresentable, CaseIterable where Self.RawValue == String {
    static var eof: Self { get }
    static var none: Self { get }
    static var separators: Set<Character> { get }
    static var comment: String { get }

    var pattern: String { get }
}
extension Lexable {
    var pattern: String { rawValue }
}

public struct Token<T: Lexable>: CustomStringConvertible, Equatable {
    public let kind: T
    public let value: Substring

    public var description: String { "\(kind)[\(value)]" }

    public static func == (lhs: Token<T>, rhs: Token<T>) -> Bool {
        return lhs.kind == rhs.kind && lhs.value == rhs.value
    }
}

extension Substring {
    func matches(pattern: String) -> String.Index? {
        guard let matchRange = range(of: pattern, options: .regularExpression),
            matchRange.lowerBound == startIndex
        else { return nil }
        return matchRange.upperBound
    }
}

public struct Lexer<T: Lexable> {

    private(set) var input: String
    private(set) var index: String.Index
    private(set) var column: Int
    private(set) var line: Int
    private var commentRegex: String

    var currentChar: Character { input[index] }
    var remainingStr: Substring { input[index...] }
    var endIndex: String.Index { input.endIndex }

    public init() {
        self.input = ""
        index = self.input.startIndex
        column = 0
        line = 0
        commentRegex = T.comment + ".*\n"
    }

    @discardableResult
    public mutating func run(input: String) throws -> [Token<T>] {
        self.input = input
        index = self.input.startIndex
        column = 0
        line = 0

        var stream = [Token<T>]()

        removeSeparators()

        while !isEnd() {
            var longestMatch: T?
            var longestMatchIdx = index

            if let startIdx = remainingStr.matches(pattern: commentRegex) {
                move(to: startIdx)
            }

            removeSeparators()

            for tokenKind in T.allCases {
                if let currentMatchIdx = remainingStr.matches(pattern: tokenKind.pattern) {
                    print("tokenKind: \(tokenKind), index: \(currentMatchIdx), longest: \(longestMatchIdx)")
                    if currentMatchIdx > longestMatchIdx {
                        longestMatch = tokenKind
                        longestMatchIdx = currentMatchIdx
                    }
                }
            }

            guard let matchedToken = longestMatch else {
                throw SwiftLexError.noTokenMatched(at: remainingStr.prefix(20),
                                                 line: line)
            }

            let hitString = slice(to: longestMatchIdx)
            let token = Token(kind: matchedToken, value: hitString)
            let start = column
            let end = start + hitString.count
            print("token: \(token), start: \(start), end: \(end)")
            
            stream.append(token)
            move(to: longestMatchIdx)
            removeSeparators()
        }

        stream.append(Token(kind: T.eof, value: ""))
        return stream
    }

    mutating func next() {
        index = input.index(after: index)
    }

    func slice(to end: String.Index, from start_: String.Index? = nil) -> Substring {
        let start = start_ ?? self.index
        return input[start ..< end]
    }

    mutating func move(to index: String.Index) {
        assert(index <= endIndex)
        while self.index < index {
            if (currentChar == "\n") {
                column = 0
                line += 1
            } else {
                column += 1
            }
            next()
        }
    }

    func isEnd() -> Bool { index == endIndex }

    mutating func removeSeparators() {
        while !isEnd() {
            if T.separators.contains(input[index]) {
                if (currentChar == "\n") {
                    column = 0
                    line += 1
                } else {
                    column += 1
                }
                next()
            } else { break }
        }
    }

}

