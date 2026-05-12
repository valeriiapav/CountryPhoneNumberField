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

    public func regionCode(for number: String, defaultRegionCode: String) -> String? {
        bridge.regionCode(forNumber: number, regionCode: defaultRegionCode)
    }

    public func nationalNumber(for number: String, regionCode: String) -> String? {
        bridge.nationalNumber(forNumber: number, regionCode: regionCode)
    }

    public func isFixedLine(_ number: String, regionCode: String) -> Bool {
        bridge.isFixedLineNumber(number, regionCode: regionCode)
    }
}
