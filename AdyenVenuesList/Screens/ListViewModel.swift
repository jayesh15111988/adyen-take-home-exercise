//
//  ListViewModel.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation
import UIKit
import CoreLocation

enum LocationMode {

    case undetermined
    case requestMade
    case currentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)

    var locationDescription: String? {
        let location: String
        switch self {
        case .currentLocation:
            location = "Current Location"
        case .undetermined, .requestMade:
            return nil
        }
        return "Showing results for \(location)"
    }
}

struct VenueViewModel {
    let locationName: String
    let distance: String
    let category: CategoryViewModel?
    let formattedAddress: String
    let neighborhoods: String?
}

struct ListScreenViewModel {
    let venues: [VenueViewModel]
}

struct CategoryViewModel {
    let name: String
}

final class ListViewModel: NSObject {

    weak var view: (ListViewable & UIViewController)?

    let requestHandler: RequestHandling

    @Published var radius: Float = 2

    @Published var locationMode: LocationMode

    private var retryEnabled = false

    private var previousRadius: Float = 0
    @Published var previousLocationMode: LocationMode = .undetermined

    private var previousVenuesSortOrder: VenuesSortOrder = .relevance

    private var venuesSortOrder: VenuesSortOrder = .relevance

    private enum Constants {
        static let distanceFilter: CGFloat = 100.0
    }

    var locationManager: CLLocationManager?

    private let alertDisplayUtility: AlertDisplayable

    init(requestHandler: RequestHandling, alertDisplayUtility: AlertDisplayable = AlertDisplayUtility()) {
        self.requestHandler = requestHandler
        self.alertDisplayUtility = alertDisplayUtility
        self.locationMode = .undetermined
    }

    func updateVenuesSortOrder(with sortIndex: Int) {
        if let sortOrderType = VenuesSortOrder(rawValue: sortIndex) {
            self.venuesSortOrder = sortOrderType
            fetchVenues()
        } else {
            assertionFailure("Unable to convert raw index value into VenuesSortOrder enum type. Expected index within range 0, 1. Received \(sortIndex)")
        }
    }

    private func fetchCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager?.distanceFilter = Constants.distanceFilter
                self.locationManager?.delegate = self
            }
        } else {
            self.retryEnabled = false
            view?.displayError(with: "No location service enabled. Please enable the location service to view weather at the current location", showRetryButton: self.retryEnabled)
        }

        switch locationManager?.authorizationStatus {
        case .authorizedWhenInUse:
            self.locationManager?.startUpdatingLocation()
        case .notDetermined:
            let requestUserLocationMessage = "Are you sure you want to share your location with Venues list app while app is running? (We won't store any data on server and will be used only for sole purpose of showing venues at current accurate location)"
            let shareLocationAction = UIAlertAction(title: "Share location", style: .default) { action in
                self.requestLocationPermission()
                self.locationManager?.startUpdatingLocation()
            }

            let denyLocationAction = UIAlertAction(title: "No", style: .default) { [weak self] _ in
                self?.view?.stopAnimating()
            }

            if let view = view {
                alertDisplayUtility.showAlert(with: "Request Location", message: requestUserLocationMessage, actions: [denyLocationAction, shareLocationAction], parentController: view)
            } else {
                view?.displayError(with: "Something went wrong. Please try again later", showRetryButton: false)
            }
        default:
            self.retryEnabled = false
            self.view?.displayError(with: "No location permission granted. Please enable location permission for Weather app from Settings menu", showRetryButton: self.retryEnabled)
        }
    }

    private func requestLocationPermission() {
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.requestWhenInUseAuthorization()
    }

    func fetchVenues() {

        if case .undetermined = locationMode {
            return
        }

        if case .currentLocation = locationMode {
            loadVenuesFromAPI()
        } else {
            fetchCurrentLocation()
        }
    }

    private func shouldFireRequest() -> Bool {
        if radius != previousRadius || locationMode != previousLocationMode || previousVenuesSortOrder != venuesSortOrder || retryEnabled {
            return true
        }
        return false
    }

    func loadVenuesFromAPI() {
        // Prevent app from sending duplicate requests
        guard shouldFireRequest() else {
            return
        }

        self.retryEnabled = false
        self.view?.startAnimating()

        requestHandler.request(route: .getVenuesList(radius: Int(radius) * 1000, locationMode: locationMode, sortOrder: venuesSortOrder)) { [weak self] (result: Result<VenuesList, DataLoadError>) -> Void in
            guard let self = self else {
                self?.view?.displayError(with: "Something went wrong. Please try again later", showRetryButton: false)
                return
            }

            switch result {
            case .success(let response):
                self.previousRadius = self.radius
                self.previousLocationMode = self.locationMode
                self.previousVenuesSortOrder = self.venuesSortOrder
                self.view?.didFetchVenues(listScreenViewModel: self.getListScreenViewModel(from: response.results))
            case .failure(let dataLoadError):
                self.retryEnabled = true
                self.view?.displayError(with: dataLoadError.errorMessageString(), showRetryButton: self.retryEnabled)
            }
        }
    }

    func requestVenuesAtCurrentLocation() {
        if case .undetermined = locationMode {
            self.locationMode = .requestMade
        }
        self.fetchVenues()
    }

    func getListScreenViewModel(from venues: [Venue]) -> ListScreenViewModel {
        let venueViewModels = venues.map { venue -> VenueViewModel in
            let distanceInKilometer: Double = venue.distance / 1000.0
            let distanceValue = "Distance: \(distanceInKilometer) KM"

            let neighborhoods: String?

            if let neighborhood = venue.location.neighborhood {
                neighborhoods = "Neighborhood: \(neighborhood.joined(separator: ", "))"
            } else {
                neighborhoods = nil
            }

            let categoryViewModel: CategoryViewModel?

            if let category = venue.categories.first {
                categoryViewModel = CategoryViewModel(name: category.name)
            } else {
                categoryViewModel = nil
            }

            return VenueViewModel(locationName: venue.name, distance: distanceValue, category: categoryViewModel, formattedAddress: venue.location.formattedAddress, neighborhoods: neighborhoods)
        }

        return ListScreenViewModel(venues: venueViewModels)
    }
}

extension ListViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latestLocation = locations.last {
            self.locationMode = .currentLocation(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
            self.loadVenuesFromAPI()
        } else {
            self.retryEnabled = false
            view?.displayError(with: "Unable to get current location data. Please enable location access to this app or try again", showRetryButton: self.retryEnabled)
        }
    }
}

// Equatable protocol to compare location mode equality
extension LocationMode: Equatable {
    static func ==(lhs: LocationMode, rhs: LocationMode) -> Bool {
        switch (lhs, rhs) {
        case (.undetermined, .undetermined), (.requestMade, .requestMade):
            return true
        case let (.currentLocation(lhsLatitude, lhsLongitude), .currentLocation(rhsLatitude, rhsLongitude)):
            return lhsLatitude == rhsLatitude && lhsLongitude == rhsLongitude
        default:
            return false
        }
    }
}
