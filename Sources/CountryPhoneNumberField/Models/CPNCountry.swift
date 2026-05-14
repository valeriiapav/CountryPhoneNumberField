//
//  Country.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation

public struct CPNCountry: Codable, Equatable, Hashable {
    public let name: String
    public let ukrName: String
    public let code: String
    public let emoji: String
    public let unicode: String
    public let image: String
    public let dialCode: String

    enum CodingKeys: String, CodingKey {
        case name
        case ukrName = "ukr_name"
        case code
        case emoji
        case unicode
        case image
        case dialCode = "dial_code"
    }
}
