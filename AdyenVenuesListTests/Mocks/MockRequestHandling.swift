//
//  MockRequestHandling.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import Foundation

@testable import AdyenVenuesList

class MockRequestHandler: RequestHandling {

    var toFail = false

    func request<T>(route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) where T : Decodable {

        if toFail {
            completion(.failure(.genericError("Something went wrong")))
        }

        let venuesList: T? = JSONDataReader.getModelFromJSONFile(with: "venues")
        completion(.success(venuesList!))
    }
}
