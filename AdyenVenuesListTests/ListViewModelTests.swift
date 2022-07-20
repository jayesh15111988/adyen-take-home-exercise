//
//  ListViewModelTests.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import XCTest

@testable import AdyenVenuesList

final class ListViewModelTests: XCTestCase {
    func testThatViewModelCorrectlySetsTheStateWhenTheRequestSucceeds() {
        let viewModel = ListViewModel(requestHandler: MockRequestHandler())
        let view = MockListViewController()
        viewModel.view = view

        viewModel.loadVenuesFromAPI()

        XCTAssertEqual(view.listScreenViewModel?.venues.count, 10)

        let firstVenueViewModel = view.listScreenViewModel?.venues[0]

        XCTAssertEqual(firstVenueViewModel?.locationName, "Nijiya Market")
        XCTAssertEqual(firstVenueViewModel?.distance, "Distance: 1.307 KM")
        XCTAssertEqual(firstVenueViewModel?.category?.name, "Grocery Store / Supermarket")
        XCTAssertEqual(firstVenueViewModel?.formattedAddress, "3860 Convoy St, San Diego, CA 92111")
        XCTAssertEqual(firstVenueViewModel?.neighborhoods, "Neighborhood: Clairemont Mesa East")

        let lastVenueViewModel = view.listScreenViewModel?.venues[9]

        XCTAssertEqual(lastVenueViewModel?.locationName, "Bud\'s Louisiana Cafe")
        XCTAssertEqual(lastVenueViewModel?.distance, "Distance: 4.043 KM")
        XCTAssertEqual(lastVenueViewModel?.category?.name, "Cajun / Creole Restaurant")
        XCTAssertEqual(lastVenueViewModel?.formattedAddress, "4320 Viewridge Ave, San Diego, CA 92123")
        XCTAssertEqual(lastVenueViewModel?.neighborhoods, "Neighborhood: Eastern San Diego")
    }

    func testThatViewModelCorrectlySetsTheStateWhenTheRequestFails() {
        let requestHandler = MockRequestHandler()
        requestHandler.toFail = true
        let viewModel = ListViewModel(requestHandler: requestHandler)
        let view = MockListViewController()
        viewModel.view = view

        viewModel.loadVenuesFromAPI()
        XCTAssertEqual(view.errorMessage, "Something went wrong")
    }
}
