//
//  ListCell.swift
//  AdyenVenuesList
//
//  Created by Jayesh Kawli on 7/18/22.
//

import UIKit

final class ListCell: UITableViewCell {

    var showFullAddressButtonPressedClosure: (() -> Void)?

    private enum Constants {
        static let horizontalPadding: CGFloat = 8.0
        static let verticalPadding: CGFloat = 8.0
        static let horizontalSpacing: CGFloat = 8.0
        static let verticalSpacing: CGFloat = 8.0
        static let imageHeight: CGFloat = 32.0
        static let imageWidth: CGFloat = 32.0
        static let showFullAddressButtonCornerRadius: CGFloat = 16.0
    }

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Style.Fonts.medium
        return label
    }()

    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Style.Fonts.medium
        return label
    }()

    private let neighborhoodsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Style.Fonts.medium
        return label
    }()

    private let categoryNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Style.Fonts.medium
        return label
    }()

    private let showFullAddressButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Full Address", for: .normal)
        button.setTitleColor(.black, for: .normal)

        button.layer.cornerRadius = Constants.showFullAddressButtonCornerRadius
        button.clipsToBounds = true
        button.backgroundColor = .lightGray

        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(neighborhoodsLabel)
        contentView.addSubview(categoryNameLabel)
        contentView.addSubview(showFullAddressButton)

        selectionStyle = .none

        showFullAddressButton.addTarget(self, action: #selector(showFullAddressButtonPressed), for: .touchUpInside)
    }

    @objc private func showFullAddressButtonPressed() {
        showFullAddressButtonPressedClosure?()
    }

    func layoutViews() {

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPadding),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalSpacing)
        ])

        NSLayoutConstraint.activate([
            distanceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.verticalPadding),
            distanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalSpacing)
        ])

        NSLayoutConstraint.activate([
            neighborhoodsLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: Constants.verticalSpacing),
            neighborhoodsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            neighborhoodsLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: -Constants.horizontalSpacing)
        ])

        NSLayoutConstraint.activate([
            categoryNameLabel.topAnchor.constraint(equalTo: neighborhoodsLabel.bottomAnchor, constant: Constants.verticalSpacing),
            categoryNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            categoryNameLabel.trailingAnchor.constraint(equalTo: distanceLabel.trailingAnchor, constant: -Constants.horizontalSpacing)
        ])

        NSLayoutConstraint.activate([
            showFullAddressButton.topAnchor.constraint(equalTo: categoryNameLabel.bottomAnchor, constant: Constants.verticalSpacing),
            showFullAddressButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            showFullAddressButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            showFullAddressButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPadding),
        ])
    }

    func configure(with viewModel: VenueViewModel) {
        nameLabel.text = viewModel.locationName
        distanceLabel.text = viewModel.distance
        neighborhoodsLabel.text = viewModel.neighborhoods
        categoryNameLabel.text = viewModel.category?.name
        showFullAddressButton.isHidden = showFullAddressButtonPressedClosure == nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        distanceLabel.text = nil
        neighborhoodsLabel.text = nil
        categoryNameLabel.text = nil
    }
}

extension ListCell: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
