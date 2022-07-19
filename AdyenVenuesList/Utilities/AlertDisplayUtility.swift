//
//  AlertDisplayUtility.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import UIKit

protocol AlertDisplayable: AnyObject {
    func showAlert(with title: String, message: String, actions: [UIAlertAction], parentController: UIViewController)
}

final class AlertDisplayUtility: AlertDisplayable {

    /// A method to show an alert message
    /// - Parameters:
    ///   - title: Title to show on alert dialogue
    ///   - message: A message to display with detailed description why alert was shown
    ///   - actions: The list of actions user want to add to alertController
    ///   - parentController: A parent controller on which to show this alert dialogue
    func showAlert(with title: String, message: String, actions: [UIAlertAction], parentController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if !actions.isEmpty {
            actions.forEach { alertController.addAction($0) }
        } else {
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        parentController.present(alertController, animated: true)
    }
}

