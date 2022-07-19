//
//  ListViewModel.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation
import CoreLocation

enum LocationMode {
    case defaultLocation(latitude: Double, longitude: Double)
    case currentLocation(latitude: Double, longitude: Double)

    var locationDescription: String {
        let location: String
        switch self {
        case .defaultLocation:
            location = "Cupertino"
        case .currentLocation:
            location = "Current Location"
        }
        return "Showing results for \(location)"
    }

    var toggleModeDescription: String {
        switch self {
        case .defaultLocation:
            return "Search Venues in Current Location"
        case .currentLocation:
            return "Search Venues at Cupertino"
        }
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

final class ListViewModel {

    weak var view: ListViewable?

    let requestHandler: RequestHandling

    @Published var radius: Float = 2

    @Published var locationMode: LocationMode

    private var previousRadius: Float = 0

    // Default latitude and longitude - Belong to Apple headquarter
    private var latitude: Double = 37.32
    private var longitude: Double = -122.03

    var locationManager: CLLocationManager?

    init(requestHandler: RequestHandling) {
        self.requestHandler = requestHandler
        self.locationMode = .defaultLocation(latitude: latitude, longitude: longitude)
    }

    func toggleLocationMode() {
        switch locationMode {
        case .defaultLocation:
            locationMode = .currentLocation(latitude: 20, longitude: 20)
        case .currentLocation:
            locationMode = .defaultLocation(latitude: latitude, longitude: longitude)
        }
    }

    func fetchVenues() {

        // Prevent app from sending duplicate requests
        guard radius != previousRadius else {
            return
        }

        self.previousRadius = radius

        requestHandler.request(route: .getVenuesList(radius: Int(radius) * 1000, latitude: latitude, longitude: longitude)) { [weak self] (result: Result<VenuesList, DataLoadError>) -> Void in
            guard let self = self else {
                self?.view?.displayError(with: "Something went wrong. Please try again later")
                return
            }

            switch result {
            case .success(let response):
                self.view?.didFetchVenues(listScreenViewModel: self.getListScreenViewModel(from: response.results))
            case .failure(let dataLoadError):
                self.view?.displayError(with: dataLoadError.errorMessageString())
            }
        }
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
