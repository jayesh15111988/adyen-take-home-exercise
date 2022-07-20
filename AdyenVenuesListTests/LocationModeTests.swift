//
//  LocationModeTests.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import XCTest

@testable import AdyenVenuesList

final class LocationModeTests: XCTestCase {
    func testThatLocationModeReturnsCorrectLocationDescriptionForCurrentCase() {

        let undetermined = LocationMode.undetermined
        XCTAssertNil(undetermined.locationDescription)

        let locationRequestMade = LocationMode.requestMade
        XCTAssertNil(locationRequestMade.locationDescription)

        let currentLocation = LocationMode.currentLocation(latitude: 23, longitude: 98)
        XCTAssertEqual(currentLocation.locationDescription, "Showing results for Current Location")
    }

    func testThatLocationModePassedEqualityCheck() {
        let undetermined = LocationMode.undetermined
        XCTAssertEqual(undetermined, undetermined)

        let locationRequestMade = LocationMode.requestMade
        XCTAssertEqual(locationRequestMade, locationRequestMade)

        let currentLocation = LocationMode.currentLocation(latitude: 23, longitude: 98)
        XCTAssertEqual(currentLocation, currentLocation)

        XCTAssertNotEqual(undetermined, locationRequestMade)
        XCTAssertNotEqual(locationRequestMade, currentLocation)
        XCTAssertNotEqual(currentLocation, undetermined)
    }
}
