//
//  PhoneNumberValidator.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 11.05.2026.
//

import Foundation
import PhoneNumberBridge

public final class PhoneNumberValidator {

    private let bridge = PhoneNumberBridge()

    public init() {}

    public func isValid(_ number: String, regionCode: String) -> Bool {
        bridge.isValidNumber(number, regionCode: regionCode)
    }

    public func formatE164(_ number: String, regionCode: String) -> String? {
        bridge.formatE164(number, regionCode: regionCode)
    }
}
