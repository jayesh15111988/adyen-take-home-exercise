//
//  ListViewModel.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation


enum LocationMode {
    case defaultLocation
    case currentLocation

    var locationDescription: String {
        switch self {
        case .defaultLocation:
            return "Cupertino"
        case .currentLocation:
            return "Current Location"
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
    let locationDescription: String
}

struct CategoryViewModel {
    let name: String
}

final class ListViewModel {

    weak var view: ListViewable?

    let requestHandler: RequestHandling

    @Published var radius: Float = 2

    private var previousRadius: Float = 0

    var locationMode: LocationMode = .defaultLocation

    // Default latitude and longitude - Belong to Apple headquarter
    private var latitude: Double = 37.32
    private var longitude: Double = -122.03

    init(requestHandler: RequestHandling) {
        self.requestHandler = requestHandler
    }

    func fetchVenues() {

        // Prevent app from sending duplicate requests
        guard radius != previousRadius else {
            return
        }
        print("Sending request for \(radius)")

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

        let locationDescription = "Showing results for \(locationMode.locationDescription)"
        return ListScreenViewModel(venues: venueViewModels, locationDescription: locationDescription)
    }
}
