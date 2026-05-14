//
//  PhoneAsYouTypeFormatter.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 14.05.2026.
//

import Foundation
import NBPhoneNumber

/// Swift wrapper around `NBAsYouTypeFormatter` that handles country-code
/// stripping so callers always work with the **national** portion only.
///
/// Usage:
/// ```swift
/// let formatter = PhoneAsYouTypeFormatter()
/// formatter.configure(regionCode: "UA", dialCode: "+380")
///
/// // Call with raw digits the user has typed (no dial code, no spaces):
/// let display = formatter.format(digits: "0671234")  // → "067 123 4"
/// ```
@MainActor
public final class PhoneAsYouTypeFormatter {

    // MARK: - Private state

    private var nbFormatter: NBAsYouTypeFormatter?
    private var dialCode: String = ""
    private var dialCodeDigits: String = ""   // digits-only version of the dial code

    // MARK: - Init

    public init() {}

    // MARK: - Configuration

    /// Call this whenever the selected country changes.
    public func configure(regionCode: String, dialCode: String) {
        self.dialCode = dialCode
        self.dialCodeDigits = dialCode.filter { $0.isNumber }
        self.nbFormatter = NBAsYouTypeFormatter(regionCode: regionCode)
    }

    // MARK: - Formatting

    /// Format `digits` — the **raw national digits** typed by the user
    /// (no dial code prefix, no spaces).  Returns the formatted national portion.
    ///
    /// Returns `digits` unchanged when no country has been configured yet.
    public func format(digits: String) -> String {
        guard let nbFormatter else { return digits }
        guard !digits.isEmpty else { return "" }

        // Feed the full international number to the formatter
        // e.g.  dialCode = "+380",  digits = "0671234567"
        //       fullNumber = "+3800671234567"
        let fullNumber = dialCode + digits

        // inputString: is nullable in ObjC; fall back to raw digits on nil
        guard let formatted = nbFormatter.inputString(fullNumber) else {
            return digits
        }

        // Strip the leading dial code (with or without trailing space)
        // e.g. "+380 067 123 45 67"  →  "067 123 45 67"
        return removingDialCode(from: formatted)
    }

    // MARK: - Private helpers

    private func removingDialCode(from formatted: String) -> String {
        // The formatter typically emits "dialCode<space>national" once enough
        // digits are entered, and just "dialCode national…" while still partial.
        if formatted.hasPrefix(dialCode + " ") {
            return String(formatted.dropFirst(dialCode.count + 1))
        }
        if formatted.hasPrefix(dialCode) {
            return String(formatted.dropFirst(dialCode.count))
        }
        // Unexpected format — return as-is so we never lose user input
        return formatted
    }
}
