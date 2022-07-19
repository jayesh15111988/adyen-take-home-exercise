//
//  ListViewController.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import UIKit
import Combine

protocol ListViewable: AnyObject {
    func didFetchVenues(listScreenViewModel: ListScreenViewModel)
    func displayError(with message: String)
}

final class ListViewController: UIViewController, ListViewable {

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let estimatedRowHeight: CGFloat = 44.0
        static let verticalPadding: CGFloat = 16.0
        static let sliderStep: Float = 2
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

    private let sliderLabel: UILabel = {
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

    private let sliderControl: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 2
        slider.maximumValue = 30
        slider.value = 2

        return slider
    }()

    private let viewModel: ListViewModel
    private let alertDisplayUtility: AlertDisplayable

    private var cancellables:Set<AnyCancellable> = []

    init(viewModel: ListViewModel, alertDisplayUtility: AlertDisplayable = AlertDisplayUtility()) {
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
        view.addSubview(sliderLabel)
        view.addSubview(sliderControl)
        view.addSubview(locationDetailsLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)

        self.title = "Venues"

        viewModel.$radius.sink { _ in

        } receiveValue: { [weak self] currentRadiusValue in
            self?.sliderLabel.text = "Showing results in the radius of \(currentRadiusValue) KM"
        }.store(in: &cancellables)


        self.sliderControl.addTarget(self, action: #selector(sliderControlChanged), for: .valueChanged)

        tableView.dataSource = self

        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    }

    func layoutViews() {

        NSLayoutConstraint.activate([
            sliderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            sliderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            sliderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            sliderControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            sliderControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            sliderControl.topAnchor.constraint(equalTo: sliderLabel.bottomAnchor, constant: Constants.verticalPadding),
        ])

        NSLayoutConstraint.activate([
            locationDetailsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            locationDetailsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            locationDetailsLabel.topAnchor.constraint(equalTo: sliderControl.bottomAnchor, constant: Constants.verticalPadding),
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

    @objc private func sliderControlChanged(sender: UISlider) {
        let currentValue = round(sender.value / Constants.sliderStep) * Constants.sliderStep
        viewModel.radius = currentValue
        sender.value = currentValue
        self.loadVenues()
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
