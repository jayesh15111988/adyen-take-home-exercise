//
//  VenuesList.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation

struct VenuesList: Decodable {
    let results: [Venue]
}

struct Venue: Decodable {
    let name: String
    let distance: Double
    let location: Location
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case name
        case distance
        case location
        case categories
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.distance = try container.decode(Double.self, forKey: .distance)
        self.location = try container.decode(Location.self, forKey: .location)

        self.categories = try container.decode([Category].self, forKey: .categories)
    }
}

// It wasn't really clear from API documentation which fields are optional
// And which not, so had to do trial and error to find about fields nullability
struct Location: Decodable {
    let formattedAddress: String
    let locality: String?
    let region: String?
    let neighborhood: [String]?
}

struct Category: Decodable {
    let name: String
}
