//
//  CountryPhoneNumberField.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation
import UIKit

public final class CountryPhoneNumberField: UIView {

    public var didChangeCountry: ((Country) -> Void)?
    public var didValidatePhone: ((Bool) -> Void)?

    public private(set) var selectedCountry: Country?
    public private(set) var isValid: Bool = false

    public var phoneNumber: String {
        phoneTextField.text ?? ""
    }

    public var e164PhoneNumber: String? {
        guard let selectedCountry else { return nil }
        return validator.formatE164(phoneNumber, regionCode: selectedCountry.code)
    }

    private let configuration: CountryPhoneNumberFieldConfiguration
    private let validator = PhoneNumberValidator()
    private let repository = CountryRepository()

    private let countryButton = UIButton(type: .system)
    private let phoneTextField = UITextField()

    public init(configuration: CountryPhoneNumberFieldConfiguration = .init()) {
        self.configuration = configuration
        super.init(frame: .zero)

        setupUI()
        setupActions()
        selectDefaultCountry()
    }

    required init?(coder: NSCoder) {
        self.configuration = .init()
        super.init(coder: coder)

        setupUI()
        setupActions()
        selectDefaultCountry()
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 14
        clipsToBounds = true

        let countryTitleLabel = UILabel()
        countryTitleLabel.text = configuration.countryTitle
        countryTitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        countryTitleLabel.textColor = .secondaryLabel

        countryButton.contentHorizontalAlignment = .leading
        countryButton.tintColor = .label

        let countryStack = UIStackView(arrangedSubviews: [
            countryTitleLabel,
            countryButton
        ])
        countryStack.axis = .vertical
        countryStack.spacing = 8

        let phoneTitleLabel = UILabel()
        phoneTitleLabel.text = configuration.phoneTitle
        phoneTitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        phoneTitleLabel.textColor = .secondaryLabel

        phoneTextField.placeholder = configuration.phonePlaceholder
        phoneTextField.keyboardType = .numberPad
        phoneTextField.font = .systemFont(ofSize: 17, weight: .regular)
        phoneTextField.textColor = .label

        let phoneStack = UIStackView(arrangedSubviews: [
            phoneTitleLabel,
            phoneTextField
        ])
        phoneStack.axis = .vertical
        phoneStack.spacing = 8

        let separator = UIView()
        separator.backgroundColor = .separator

        addSubview(countryStack)
        addSubview(separator)
        addSubview(phoneStack)

        countryStack.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        phoneStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            countryStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            countryStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            countryStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            countryStack.widthAnchor.constraint(equalToConstant: 150),

            separator.leadingAnchor.constraint(equalTo: countryStack.trailingAnchor, constant: 12),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.widthAnchor.constraint(equalToConstant: 1),

            phoneStack.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 16),
            phoneStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            phoneStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            phoneStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func setupActions() {
        countryButton.addTarget(self, action: #selector(didTapCountry), for: .touchUpInside)
        phoneTextField.addTarget(self, action: #selector(didEditPhone), for: .editingChanged)
    }

    private func selectDefaultCountry() {
        let country =
            repository.country(forCode: configuration.defaultCountryCode)
            ?? repository.country(forCode: "UA")
            ?? repository.countries.first

        if let country {
            select(country)
        }
    }

    private func select(_ country: Country) {
        selectedCountry = country

        var config = UIButton.Configuration.plain()
        config.image = flagImage(for: country)
        config.imagePadding = 8
        config.title = "\(country.dialCode)  ▾"
        config.baseForegroundColor = .label

        countryButton.configuration = config

        phoneTextField.text = nil
        validatePhone()

        didChangeCountry?(country)
    }

    private func flagImage(for country: Country) -> UIImage? {
        // For now emoji flag fallback.
        // Later we can load PDF/PNG/SVG assets if you add them.
        let label = UILabel()
        label.text = country.emoji
        label.font = .systemFont(ofSize: 24)
        label.sizeToFit()

        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }

        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    @objc
    private func didTapCountry() {
        let picker = CountryPickerView()
        picker.configure(countries: repository.countries, selectedCountry: selectedCountry)

        picker.didSelectCountry = { [weak self] country in
            self?.select(country)
        }
    }

    @objc
    private func didEditPhone() {
        validatePhone()
    }

    private func validatePhone() {
        guard let selectedCountry else {
            isValid = false
            didValidatePhone?(false)
            return
        }

        isValid = validator.isValid(phoneNumber, regionCode: selectedCountry.code)
        didValidatePhone?(isValid)
    }
}
