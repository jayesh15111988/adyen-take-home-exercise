//
//  JSONDataReader.swift
//  AdyenVenuesListTests
//
//  Created by Jayesh Kawli on 7/20/22.
//

import XCTest
import Foundation

final class JSONDataReader {
    static func getModelFromJSONFile<T: Decodable>(with name: String) -> T? {
        guard let pathString = Bundle(for: self).path(forResource: name, ofType: "json") else {
            XCTFail("Mock JSON file \(name).json not found")
            return nil
        }

        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            return nil
        }

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(T.self, from: jsonData)
    }
}

