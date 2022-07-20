//
//  VenuesSortOrderTests.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import XCTest

@testable import AdyenVenuesList

final class VenuesSortOrderTests: XCTestCase {
    func testThatVenuesSortOrderEnumReturnsCorrectQueryValue() {
        XCTAssertEqual(VenuesSortOrder.distance.queryValue, "distance")
        XCTAssertEqual(VenuesSortOrder.relevance.queryValue, "relevance")
    }
}
