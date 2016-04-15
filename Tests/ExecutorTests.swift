/*
 *  Copyright (c) 2016, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 */

import XCTest
import BoltsSwift

class ExecutorTests: XCTestCase {

    func testDefaultExecute() {
        let expectation = expectationWithDescription(currentTestName)

        var finished = false
        Executor.Default.execute {
            expectation.fulfill()
            finished = true
        }

        XCTAssertTrue(finished)
        waitForTestExpectations()
    }

    func testImmediateExecute() {
        let expectation = expectationWithDescription(currentTestName)

        var finished = false
        Executor.Immediate.execute {
            expectation.fulfill()
            finished = true
        }

        XCTAssertTrue(finished)
        waitForTestExpectations()
    }

    func testMainThreadSyncExecute() {
        let expectation = expectationWithDescription(currentTestName)

        var finished = false
        Executor.MainThread.execute {
            expectation.fulfill()
            finished = true
        }

        XCTAssertTrue(finished)
        waitForTestExpectations()
    }

    func testMainThreadAsyncExecute() {
        let expectation = expectationWithDescription(currentTestName)

        var finished = false
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Executor.MainThread.execute {
                finished = true
                expectation.fulfill()
            }
        }
        waitForTestExpectations()
        XCTAssertTrue(finished)
    }

    func testQueueExecute() {
        let expectation = expectationWithDescription(currentTestName)
                let semaphore = dispatch_semaphore_create(0)
        var finished = false

        Executor.Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)).execute {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            finished = true
            expectation.fulfill()
        }

        XCTAssertFalse(finished)
        dispatch_semaphore_signal(semaphore)
        waitForTestExpectations()
        XCTAssertTrue(finished)
    }

    func testClosureExecute() {
        let expectation = expectationWithDescription(currentTestName)

        Executor.Closure { closure in
            closure()
            }.execute { () -> Void in
                expectation.fulfill()
        }

        waitForTestExpectations()
    }

    func testOperationQueueExecute() {
        let expectation = expectationWithDescription(currentTestName)
        let semaphore = dispatch_semaphore_create(0)
        var finished = false

        let operationQueue = NSOperationQueue()
        Executor.OperationQueue(operationQueue).execute {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            finished = true
            expectation.fulfill()
        }

        XCTAssertFalse(finished)
        dispatch_semaphore_signal(semaphore)
        waitForTestExpectations()
        XCTAssertTrue(finished)
    }

    // MARK: Descriptions

    func testDescriptions() {
        XCTAssertFalse(Executor.Default.description.isEmpty)
        XCTAssertFalse(Executor.Immediate.description.isEmpty)
        XCTAssertFalse(Executor.MainThread.description.isEmpty)
        XCTAssertFalse(Executor.Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)).description.isEmpty)
        XCTAssertFalse(Executor.OperationQueue(NSOperationQueue.currentQueue()!).description.isEmpty)
        XCTAssertFalse(Executor.Closure({ _ in }).description.isEmpty)
    }

    func testDebugDescriptions() {
        XCTAssertFalse(Executor.Default.debugDescription.isEmpty)
        XCTAssertFalse(Executor.Immediate.debugDescription.isEmpty)
        XCTAssertFalse(Executor.MainThread.debugDescription.isEmpty)
        XCTAssertFalse(Executor.Queue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)).debugDescription.isEmpty)
        XCTAssertFalse(Executor.OperationQueue(NSOperationQueue.currentQueue()!).debugDescription.isEmpty)
        XCTAssertFalse(Executor.Closure({ _ in }).debugDescription.isEmpty)
    }
}
