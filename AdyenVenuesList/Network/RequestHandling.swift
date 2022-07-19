//
//  RequestHandling.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation

/// Protocol for the `RequestHandler`
protocol RequestHandling {
    func request<T: Decodable>(route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void)
}

