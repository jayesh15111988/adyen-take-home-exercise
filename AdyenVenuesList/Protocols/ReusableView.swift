//
//  ReusableView.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import Foundation

/// A protocol for reusable views such as Table view cells to provide
/// reuseIdentifier for cell reuse
protocol ReusableView {
    static var reuseIdentifier: String { get }
}
