import XCTest
import Quick

@testable import CBGPromiseTests

Quick.QCKMain([
        InjectorTests.self
    ],
    testCases: [
        testCase(InjectorTests.allTests)
    ]
)
