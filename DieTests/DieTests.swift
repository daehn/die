//
//  DieTests.swift
//  DieTests
//
//  Created by Silvan Dähn on 09.03.16.
//  Copyright © 2016 Silvan Dähn. All rights reserved.
//

import XCTest
@testable import Die

extension String: Error {}

class DieTests: XCTestCase {

    var callCount = 0
    var exitStatus: Int32?
    var printHistory = [String]()
    var testExpectation: XCTestExpectation?

    // MARK: - Mocking

    private func mockExit(_ status: Int32) -> Never  {
        exitStatus = status
        callCount += 1
        testExpectation?.fulfill()
        repeat { Thread.sleep(forTimeInterval: 0.1) } while (true)
    }

    func mockPrint(_ items: Any...) {
        printHistory.append(contentsOf: items.flatMap { $0 as? String })
    }

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        (callCount, exitStatus, printHistory) = (0, nil, [])
        (internalExit, internalPrint)  = (mockExit, mockPrint)
    }
    
    override func tearDown() {
        (internalExit, internalPrint) = (exit, _internalPrint)
        testExpectation = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testThatItCallsDie() {
        // when
        assertThatItCallsDie { die() }

        // then
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(exitStatus, EXIT_FAILURE)
    }

    func testThatItCallsExitAndPrintsTheMessageAndNewline() {
        // given
        let message = "🚫"
        let line: UInt = 9

        // when
        assertThatItCallsDie { die(message, line: line) }

        // then
        XCTAssertEqual(printHistory.count, 2)
        assertMessagePrinted(message, printHistory, line: line)
    }

    func testThatItCallsDieIfFalseIfExpressionEvalutesToFalse() {
        assertThatItCallsDie {
            dieIfFalse(false)
        }
    }

    func testThatItDoesNotCallDieIfFalseIfExpressionEvalutesToTrue() {
        assertThatItCallsDie(false) {
            dieIfFalse(true)
            self.testExpectation?.fulfill()
        }
    }

    func testThatItCallsDieIfTrueIfExpressionEvalutesToTrue() {
        assertThatItCallsDie {
            dieIfTrue(true)
            self.testExpectation?.fulfill()
        }
    }

    func testThatItDoesNotCallDieIfTrueIfExpressionEvalutesToFalse() {
        assertThatItCallsDie(false) {
            dieIfTrue(false)
            self.testExpectation?.fulfill()
        }
    }

    func testThatItCallsDieIfNotNil() {
        // given
        let line: UInt = 15
        
        // when
        assertThatItCallsDie {
            dieIfNotNil(42, line: line)
        }

        // then
        assertMessagePrinted("Object was supposed to be nil: 42", printHistory, line: line)
    }

    func testThatItCallsDieIfNil() {
        let optional: Int? = .none
        
        assertThatItCallsDie {
            _ = dieIfNil(optional)
        }
    }

    func testThatItDoesNotCallDieWhen_DieIfNil_isCalledWithNonNil() {
        // when
        var result: Int?

        assertThatItCallsDie(false) {
            result = dieIfNil(42)
            self.testExpectation?.fulfill()
        }

        // then
        XCTAssertEqual(result, 42)
    }

    func testThatItCallsDieOnThrow() {
        assertThatItCallsDie {
            dieOnThrow {
                throw "Error"
            }
        }
    }

    func testThatItCallsDieAndPrintsTheMessageOnThrow() {
        // given
        let message = "🚫"
        let line: UInt = #line

        // when
        assertThatItCallsDie {
            dieOnThrow(message, line: line) {
                throw "Error"
            }
        }

        // then
        XCTAssertEqual(printHistory.count, 3)
        guard let errorMessage = printHistory.first else { return XCTFail() }
        XCTAssertEqual(errorMessage, "Error: Error")
        assertMessagePrinted(message, Array(printHistory.dropFirst()), line: line)
    }

    func testThatItDoesNotCallDieIfItDoesNotThrow() {
        // given
        var solution: Int?
        assertThatItCallsDie(false) {
             solution = dieOnThrow {
                self.testExpectation?.fulfill()
                return 42
            }
        }

        // then
        XCTAssertEqual(solution, 42)
    }

    // MARK: - Helper

    func assertThatItCallsDie(_ shouldCall: Bool = true, line: UInt = #line , file: String = #file, block: @escaping () -> Void) {
        // when
        dispatchAndWaitForDie(timeout: 2, block: block)

        // then
        let expectedCount = shouldCall ? 1 : 0
        let expectedStatus: Int32? = shouldCall ? EXIT_FAILURE : nil
        let (countEqual, statusEqual) = (callCount == expectedCount, exitStatus == expectedStatus)
        let fail: (String) -> Void = { self.recordFailure(withDescription: $0, inFile: file, atLine: line, expected: true) }
        if !countEqual { fail("Incorrect die callcount, \(expectedCount) is not equal to \(callCount)") }
        if !statusEqual { fail("Incorrect exit status, \(expectedStatus) is not equal to \(exitStatus)") }
    }

    func assertMessagePrinted(_ message: String, _ history: [String], file: StaticString = #file, line: UInt) {
        guard let historyMessage = history.first, let location = history.last else { return XCTFail() }
        XCTAssertEqual(historyMessage, message)
        XCTAssertTrue(location.contains(String(describing: file)))
        XCTAssertTrue(location.contains("line \(line)"))
    }

    func dispatch(_ block: @escaping ()->()) {
        let queue = DispatchQueue(label: "test", attributes: [])
        queue.async(execute: block)
    }

    func waitWithTimeout(_ timeout: TimeInterval, block: ()->()) {
        testExpectation = expectation(description: "Wait for die() to be called")
        block()
        waitForExpectations(timeout: timeout, handler: nil)
    }

    func dispatchAndWaitForDie(timeout: TimeInterval, block: @escaping ()->()) {
        waitWithTimeout(timeout) {
            self.dispatch(block)
        }
    }
}
