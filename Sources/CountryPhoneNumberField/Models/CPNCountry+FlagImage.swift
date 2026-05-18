//
//  CPNCountry+FlagImage.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 18.05.2026.
//

import UIKit

public extension CPNCountry {

    /// Renders the country's flag emoji into a `UIImage`.
    /// - Parameter size: Desired output size. Defaults to 22×22 pt.
    func flagImage(size: CGSize = CGSize(width: 22, height: 22)) -> UIImage? {
        UIGraphicsImageRenderer(size: size).image { _ in
            (emoji as NSString).draw(
                at: CGPoint(x: 0, y: -1),
                withAttributes: [.font: UIFont.systemFont(ofSize: 18)]
            )
        }
    }
}

public extension UIImage {

    /// Renders a flag image for the given ISO-3166-1 alpha-2 country code.
    /// Returns `nil` when the code is not exactly 2 characters.
    /// - Parameter isoCode: e.g. `"UA"`, `"PL"`, `"US"`
    /// - Parameter size: Desired output size. Defaults to 22×22 pt.
    static func flag(isoCode: String, size: CGSize = CGSize(width: 22, height: 22)) -> UIImage? {
        let code = isoCode.uppercased()
        guard code.count == 2 else { return nil }
        let emoji = code.unicodeScalars.compactMap {
            Unicode.Scalar($0.value + 0x1F1A5)
        }.map(String.init).joined()
        return UIGraphicsImageRenderer(size: size).image { _ in
            (emoji as NSString).draw(
                at: CGPoint(x: 0, y: -1),
                withAttributes: [.font: UIFont.systemFont(ofSize: 18)]
            )
        }
    }
}
