//
//  Die.swift
//
//  Created by Silvan Dähn on 07.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//


/// Prints the current callstack symbols before calling exit(EXIT_FAILURE)
/// - parameter message: The error message to print as failure reason
public func die(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never  {
    if !message().isEmpty {
        internalPrint(message())
    }
    internalPrint("🚫  Failure in \(file) at line \(line)")
    internalExit(EXIT_FAILURE)
}

/// Dies if the boolean result of @c condition is @c true
public func dieIfTrue(_ condition: @autoclosure () -> Bool, file: StaticString = #file, line: UInt = #line) {
    dieIfFalse(!condition(), file: file, line: line)
}

/// Dies if the boolean result of @c condition is @c false
public func dieIfFalse(_ condition: @autoclosure () -> Bool, file: StaticString = #file, line: UInt = #line) {
    guard condition() else { die(file: file, line: line) }
}

/// Returns the result of @c closure or dies if the result is nil
public func dieIfNil<T>(_ closure: @autoclosure () -> T?, file: StaticString = #file, line: UInt = #line) -> T {
    guard let result = closure() else { die(file: file, line: line) }
    return result
}

/// Dies if the result of @c closure is not nil, useful when checking for errors
public func dieIfNotNil(_ closure: @autoclosure () -> Any?, file: StaticString = #file, line: UInt = #line) {
    if let object = closure() {
        die("Object was supposed to be nil: \(object)", file: file, line: line)
    }
}

/// Convenience method to execute throwing functions and die on throw
/// - parameter message: The error message to print as failure reason
/// - parameter block: The block to execute in which a throw will cause a die()
/// - returns: The return value of the block is forwarded
public func dieOnThrow<T>(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line, block: () throws -> T) -> T {
    do {
        return try block()
    } catch {
        internalPrint("Error: \(error)")
        die(message, file: file, line: line)
    }
}

// MARK: - Testing

// The following variables provide a way to inject different behaviours when testing
var internalExit = exit
var internalPrint = _internalPrint

func _internalPrint(_ items: Any...) {
    let output = items.map { "\($0)" }.joined(separator: " ")
    print(output)
}
