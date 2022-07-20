//
//  Style.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import UIKit

/// A style object to store all the style related things in the app
enum Style {
    enum Fonts {
        static let regular = UIFont.systemFont(ofSize: 14)
        static let medium = UIFont.systemFont(ofSize: 16)
        static let large = UIFont.systemFont(ofSize: 18)
    }

    enum CornerRadius: CGFloat {
        case `default` = 16.0
    }
}

