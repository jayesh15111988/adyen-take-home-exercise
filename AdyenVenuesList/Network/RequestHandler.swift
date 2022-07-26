//
//  RequestHandler.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation

enum DataLoadError: Error {
    case badURL
    case genericError(String)
    case noData
    case malformedContent
    case invalidResponseCode(Int)
    case decodingError(String)

    func errorMessageString() -> String {
        switch self {
        case .badURL:
            return "Invalid URL encountered. Please enter the valid URL and try again"
        case let .genericError(message):
            return message
        case .noData:
            return "No data received from the server. Please try again later"
        case .malformedContent:
            return "Received malformed content. Error may have been logged on the server to investigate further"
        case let .invalidResponseCode(code):
            return "Server returned invalid response code. Expected between the range 200-299. Server returned \(code)"
        case let .decodingError(message):
            return message
        }
    }
}

final class RequestHandler: RequestHandling {

    let urlSession: URLSession

    private var previousTask: URLSessionDataTask?

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<T: Decodable>(route: APIRoute, completion: @escaping (Result<T, DataLoadError>) -> Void) {

        if let previousTask = previousTask {
            previousTask.cancel()
        }

        let task = urlSession.dataTask(with: route.asRequest()) { (data, response, error) in

            // Ignore if this request was cancelled
            // This is to avoid firing multiple requests when user changes slider too fast
            if (error as NSError?)?.code == NSURLErrorCancelled {
               return
            }

            if let error = error {
                completion(.failure(.genericError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            if let responseCode = (response as? HTTPURLResponse)?.statusCode, responseCode != 200 {
                completion(.failure(.invalidResponseCode(responseCode)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responsePayload = try decoder.decode(T.self, from: data)
                completion(.success(responsePayload))
            } catch {
                completion(.failure(.malformedContent))
            }
        }

        task.resume()

        self.previousTask = task
    }
}
