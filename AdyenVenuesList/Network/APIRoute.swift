//
//  APIRoute.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation

enum APIRoute {
    case getVenuesList(radius: Int, latitude: Double, longitude: Double)

    private var baseURLString: String { "https://api.foursquare.com/v3/" }

    private enum AuthenticationParameters {
        static let apiKey = "fsq3iMR3vpCH4TMWIe+uU+CaNyF8fb1ROXGQftm/5t9JiLM="
    }

    private var url: URL? {
        switch self {
        case .getVenuesList:
            return URL(string: baseURLString + "places/search")
        }
    }

    private var parameters: [URLQueryItem] {

        switch self {
        case let .getVenuesList(radius, latitude, longitude):

            let latitudeLongitudeParameter = String(latitude) + "," + String(longitude)

            var queryItems: [URLQueryItem] = []

            queryItems.append(URLQueryItem(name: "ll", value: latitudeLongitudeParameter))

            if radius != 0 {
                queryItems.append(URLQueryItem(name: "radius", value: String(radius)))
            }

            return queryItems
        }
    }

    func asRequest() -> URLRequest {
        guard let url = url else {
            preconditionFailure("Missing URL for route: \(self)")
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters

        guard let parametrizedURL = components?.url else {
            preconditionFailure("Missing URL with parameters for url: \(url)")
        }

        var request = URLRequest(url: parametrizedURL)

        request.setValue(AuthenticationParameters.apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
}
