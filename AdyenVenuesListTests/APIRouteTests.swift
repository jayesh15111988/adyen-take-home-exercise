//
//  APIRouteTests.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import XCTest

@testable import AdyenVenuesList

final class APIRouteTests: XCTestCase {

    var apiRoute: APIRoute!

    override func setUp() {
        apiRoute = .getVenuesList(radius: 100, locationMode: .currentLocation(latitude: 20.0, longitude: 37.89), sortOrder: .relevance)
    }

    func testAPIRouteIsCorrectlyInitializedWithPassedParameters() {
        let request = apiRoute.asRequest()
        XCTAssertEqual(request.url?.absoluteString, "https://api.foursquare.com/v3/places/search?ll=20.0,37.89&limit=50&sort=relevance&radius=100")

        let headerFields = request.allHTTPHeaderFields!

        XCTAssertEqual(headerFields["Authorization"], "fsq3iMR3vpCH4TMWIe+uU+CaNyF8fb1ROXGQftm/5t9JiLM=")
        XCTAssertEqual(headerFields["Accept"], "application/json")
    }
}
