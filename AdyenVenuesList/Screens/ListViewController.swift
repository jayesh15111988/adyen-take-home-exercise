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
    func displayError(with message: String, showRetryButton: Bool)
    func showAlert(with title: String, message: String)
    func startAnimating()
    func stopAnimating()
}

final class ListViewController: UIViewController, ListViewable {

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let estimatedRowHeight: CGFloat = 44.0
        static let verticalPadding: CGFloat = 16.0
        static let verticalSpacing: CGFloat = 8.0
        static let sliderStep: Float = 2
        static let sliderMinimumValue: Float = 2
        static let sliderMaximumValue: Float = 30
        static let sliderDefaultValue: Float = 2
    }

    private var venuesViewModels: [VenueViewModel] = []

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        return activityIndicatorView
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
        slider.minimumValue = Constants.sliderMinimumValue
        slider.maximumValue = Constants.sliderMaximumValue
        slider.value = Constants.sliderDefaultValue
        return slider
    }()

    private let searchVenusAtCurrentLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Style.CornerRadius.default.rawValue
        button.clipsToBounds = true
        button.backgroundColor = .blue
        return button
    }()

    private let searchVenusAtCurrentLocationButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let venuesSortOrderSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Sort by Relevance", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Sort by Distance", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let viewModel: ListViewModel
    private let alertDisplayUtility: AlertDisplayable
    private var searchVenusAtCurrentLocationContainerHeightConstraint: NSLayoutConstraint?

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
    }

    @objc private func sortOrderChanged(segmentedControl: UISegmentedControl) {
        viewModel.updateVenuesSortOrder(with: segmentedControl.selectedSegmentIndex)
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(sliderLabel)
        view.addSubview(sliderControl)
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)
        view.addSubview(searchVenusAtCurrentLocationButtonContainer)
        searchVenusAtCurrentLocationButtonContainer.addSubview(searchVenusAtCurrentLocationButton)
        view.addSubview(venuesSortOrderSegmentedControl)

        searchVenusAtCurrentLocationButtonContainer.clipsToBounds = true

        searchVenusAtCurrentLocationButton.addTarget(self, action: #selector(searchVenuesAtCurrentLocation), for: .touchUpInside)

        self.title = "Venues"

        self.searchVenusAtCurrentLocationButton.setTitle("Search Venues at Current Location", for: .normal)

        viewModel.$radius.sink { _ in
            //no-op
        } receiveValue: { [weak self] currentRadiusValue in
            self?.sliderLabel.text = "Searching venues in the radius of \(currentRadiusValue) KM"
        }.store(in: &cancellables)

        self.sliderControl.addTarget(self, action: #selector(sliderControlChanged), for: .valueChanged)

        tableView.dataSource = self

        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)

        // Toggle visibility of button responsible for showing venues at the current location
        viewModel.$previousLocationMode.combineLatest(viewModel.$locationMode).receive(on: DispatchQueue.main).sink { _ in
            //no-op
        } receiveValue: { [weak self] previousLocationMode, currentLocationMode in
            self?.toggleSearchVenuesAtCurrentLocationButtonVisibility(previousLocationMode != currentLocationMode || currentLocationMode == .undetermined)
        }.store(in: &cancellables)

        venuesSortOrderSegmentedControl.addTarget(self, action: #selector(sortOrderChanged), for: .valueChanged)
    }

    @objc func searchVenuesAtCurrentLocation() {
        loadVenues()
    }

    private func layoutViews() {

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
            venuesSortOrderSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalPadding),
            venuesSortOrderSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalPadding),
            venuesSortOrderSegmentedControl.topAnchor.constraint(equalTo: sliderControl.bottomAnchor, constant: Constants.verticalPadding),
        ])

        NSLayoutConstraint.activate([
            searchVenusAtCurrentLocationButtonContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchVenusAtCurrentLocationButtonContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchVenusAtCurrentLocationButtonContainer.topAnchor.constraint(equalTo: venuesSortOrderSegmentedControl.bottomAnchor, constant: Constants.verticalSpacing)
        ])

        searchVenusAtCurrentLocationContainerHeightConstraint = searchVenusAtCurrentLocationButtonContainer.heightAnchor.constraint(equalToConstant: 0)
        searchVenusAtCurrentLocationContainerHeightConstraint?.isActive = false

        let horizontalPaddingConstraints = [
            searchVenusAtCurrentLocationButton.leadingAnchor.constraint(equalTo: searchVenusAtCurrentLocationButtonContainer.leadingAnchor, constant: Constants.horizontalPadding),
            searchVenusAtCurrentLocationButton.trailingAnchor.constraint(equalTo: searchVenusAtCurrentLocationButtonContainer.trailingAnchor, constant: -Constants.horizontalPadding)
        ]

        let verticalPaddingConstraints = [
            searchVenusAtCurrentLocationButton.topAnchor.constraint(equalTo: searchVenusAtCurrentLocationButtonContainer.topAnchor, constant: Constants.verticalPadding),
            searchVenusAtCurrentLocationButton.bottomAnchor.constraint(equalTo: searchVenusAtCurrentLocationButtonContainer.bottomAnchor, constant: -Constants.verticalPadding),
        ]

        // To be able to reduce length of searchVenusAtCurrentLocationButtonContainer to zero
        // When there is no need to re-trigger the venues list request to the API
        verticalPaddingConstraints.forEach {
            $0.priority = .defaultLow
        }

        NSLayoutConstraint.activate(horizontalPaddingConstraints)
        NSLayoutConstraint.activate(verticalPaddingConstraints)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: searchVenusAtCurrentLocationButton.bottomAnchor, constant: Constants.verticalPadding),
        ])

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadVenues() {
        viewModel.requestVenuesAtCurrentLocation()
    }

    func didFetchVenues(listScreenViewModel: ListScreenViewModel) {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
            self.venuesViewModels = listScreenViewModel.venues
            self.tableView.reloadData()
        }
    }

    func toggleSearchVenuesAtCurrentLocationButtonVisibility(_ toShow: Bool) {
        self.searchVenusAtCurrentLocationContainerHeightConstraint?.isActive = !toShow
    }

    func displayError(with message: String, showRetryButton: Bool) {

        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()

            let reloadDataAction: UIAlertAction?

            if showRetryButton {
                reloadDataAction = UIAlertAction(title: "Try Again", style: .default) { action in
                    self.loadVenues()
                }
            } else {
                reloadDataAction = nil
            }

            let ignoreAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

            self.alertDisplayUtility.showAlert(with: "Error", message: message, actions: [ignoreAction, reloadDataAction].compactMap { $0 }, parentController: self)
        }
    }

    func showAlert(with title: String, message: String) {
        self.alertDisplayUtility.showAlert(with: title, message: message, actions: [], parentController: self)
    }

    func startAnimating() {
        self.activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
    }

    @objc private func sliderControlChanged(sender: UISlider) {

        // A logic to change slider value in steps
        let currentValue = round(sender.value / Constants.sliderStep) * Constants.sliderStep
        viewModel.radius = currentValue
        sender.value = currentValue
        self.loadVenues()
    }
}

// MARK: Table view data source

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

    private func getCell(from tableView: UITableView, indexPath: IndexPath) -> ListCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else {
            fatalError("Failed to get expected kind of reusable cell from the tableView. Expected cell of type `ListCell`")
        }
        return cell
    }
}
