import Foundation

public enum SwiftLexError: Error {
    case noTokenMatched(at: Substring, line: Int)
}

extension SwiftLexError : LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .noTokenMatched(at: str, line: line):
            return "No token matched \(str), line: \(line)"
        }
    }
}