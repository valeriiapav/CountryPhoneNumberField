//
//  CountryPickerView.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation
import UIKit

final class CountryPickerView: UIPickerView {

    var didSelectCountry: ((CPNCountry) -> Void)?

    private var countries: [CPNCountry] = []

    private var selectedCountry: CPNCountry?

    override init(frame: CGRect) {
        super.init(frame: frame)

        dataSource = self
        delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        dataSource = self
        delegate = self
    }

    func configure(
        countries: [CPNCountry],
        selectedCountry: CPNCountry?
    ) {
        self.countries = countries
        self.selectedCountry = selectedCountry

        reloadAllComponents()

        if let selectedCountry,
           let index = countries.firstIndex(of: selectedCountry) {
            selectRow(index, inComponent: 0, animated: false)
        }
    }

    func setCountry(_ country: CPNCountry) {
        selectedCountry = country

        guard let index = countries.firstIndex(of: country) else { return }

        selectRow(index, inComponent: 0, animated: true)
    }
}

// MARK: - UIPickerViewDataSource

extension CountryPickerView: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        countries.count
    }
}

// MARK: - UIPickerViewDelegate

extension CountryPickerView: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        let country = countries[row]

        return "\(country.emoji)  \(country.name)  \(country.dialCode)"
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        let country = countries[row]

        selectedCountry = country
        didSelectCountry?(country)
    }
}
