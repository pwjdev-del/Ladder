import Foundation
import os

enum Log {
    private static let logger = Logger(subsystem: "com.ladder.app", category: "app")

    static func error(_ message: @autoclosure @escaping () -> String, file: String = #fileID, line: Int = #line) {
        logger.error("\(file):\(line) \(message())")
    }

    static func warn(_ message: @autoclosure @escaping () -> String, file: String = #fileID, line: Int = #line) {
        logger.warning("\(file):\(line) \(message())")
    }

    static func info(_ message: @autoclosure @escaping () -> String) {
        logger.info("\(message())")
    }
}
