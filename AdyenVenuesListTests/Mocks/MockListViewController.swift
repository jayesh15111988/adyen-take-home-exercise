//
//  MockListViewController.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import Foundation

@testable import AdyenVenuesList
import UIKit

class MockListViewController: UIViewController & ListViewable {

    var listScreenViewModel: ListScreenViewModel?
    var errorMessage: String?
    var animating = false

    func didFetchVenues(listScreenViewModel: ListScreenViewModel) {
        self.listScreenViewModel = listScreenViewModel
    }

    func displayError(with message: String, showRetryButton: Bool) {
        self.errorMessage = message
    }

    func showAlert(with title: String, message: String) {
        // no-op
    }

    func startAnimating() {
        animating = true
    }

    func stopAnimating() {
        animating = false
    }
}
