//
//  ListViewController.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import UIKit

protocol ListViewable: AnyObject {
    func didFetchVenues(listScreenViewModel: ListScreenViewModel)
    func displayError(with message: String)
}

final class ListViewController: UIViewController, ListViewable {

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let estimatedRowHeight: CGFloat = 44.0
        static let verticalPadding: CGFloat = 16.0
    }

    private var venuesViewModels: [VenueViewModel] = []

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
    }()

    private let locationDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private let viewModel: ListViewModeling
    private let alertDisplayUtility: AlertDisplayable

    init(viewModel: ListViewModeling, alertDisplayUtility: AlertDisplayable = AlertDisplayUtility()) {
        self.viewModel = viewModel
        self.alertDisplayUtility = alertDisplayUtility
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
        loadVenues()
    }

    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(locationDetailsLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)

        self.title = "Venues"

        tableView.dataSource = self

        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    }

    func layoutViews() {

        NSLayoutConstraint.activate([
            locationDetailsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            locationDetailsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            locationDetailsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: locationDetailsLabel.bottomAnchor, constant: Constants.verticalPadding),
        ])

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func loadVenues() {
        activityIndicatorView.startAnimating()
        viewModel.fetchVenues()
    }

    func didFetchVenues(listScreenViewModel: ListScreenViewModel) {
        DispatchQueue.main.async {
            self.locationDetailsLabel.text = listScreenViewModel.locationDescription
            self.activityIndicatorView.stopAnimating()
            self.venuesViewModels = listScreenViewModel.venues
            self.tableView.reloadData()
        }
    }

    func displayError(with message: String) {

        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()

            let reloadDataAction = UIAlertAction(title: "Try Again", style: .default) { action in
                self.loadVenues()
            }

            let ignoreAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

            self.alertDisplayUtility.showAlert(with: "Error", message: message, actions: [ignoreAction, reloadDataAction], parentController: self)
        }
    }

    func showAlert(with title: String, message: String) {
        self.alertDisplayUtility.showAlert(with: title, message: message, actions: [], parentController: self)
    }
}

// MARK: Table view data source and delegates

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venuesViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(from: tableView, indexPath: indexPath)
        let viewModel = venuesViewModels[indexPath.row]
        cell.showFullAddressButtonPressedClosure = { [weak self] in
            self?.showAlert(with: viewModel.locationName, message: viewModel.formattedAddress)
        }
        cell.configure(with: viewModel)
        return cell
    }

    func getCell(from tableView: UITableView, indexPath: IndexPath) -> ListCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else {
            fatalError("Failed to get expected kind of reusable cell from the tableView. Expected cell of type `ListCell`")
        }
        return cell
    }
}
