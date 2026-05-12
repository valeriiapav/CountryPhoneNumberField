//
//  CountryPhoneNumberFieldConfiguration.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation

public struct CountryPhoneNumberFieldConfiguration {
    public var countryTitle: String
    public var phoneTitle: String
    public var phonePlaceholder: String
    public var defaultCountryCode: String

    public init(
        countryTitle: String = "Country",
        phoneTitle: String = "Phone number",
        phonePlaceholder: String = "Enter number",
        defaultCountryCode: String = "UA"
    ) {
        self.countryTitle = countryTitle
        self.phoneTitle = phoneTitle
        self.phonePlaceholder = phonePlaceholder
        self.defaultCountryCode = defaultCountryCode
    }
}
