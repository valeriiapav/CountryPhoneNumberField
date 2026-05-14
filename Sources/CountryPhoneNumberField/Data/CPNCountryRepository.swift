//
//  CountryRepository.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation

public final class CPNCountryRepository {

    public private(set) var countries: [CPNCountry] = []

    public init() {
        self.countries = Self.loadCountries()
    }

    public func country(forCode code: String) -> CPNCountry? {
        countries.first {
            $0.code.caseInsensitiveCompare(code) == .orderedSame
        }
    }

    public func countries(including codes: [String]) -> [CPNCountry] {
        let normalizedCodes = Set(codes.map { $0.uppercased() })
        return countries.filter {
            normalizedCodes.contains($0.code.uppercased())
        }
    }

    public func countries(excluding codes: [String]) -> [CPNCountry] {
        let normalizedCodes = Set(codes.map { $0.uppercased() })
        return countries.filter {
            !normalizedCodes.contains($0.code.uppercased())
        }
    }

    private static func loadCountries() -> [CPNCountry] {
        guard let url = Bundle.module.url(forResource: "Country", withExtension: "json") else {
            assertionFailure("Country.json not found in package resources")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let countries = try JSONDecoder().decode([CPNCountry].self, from: data)

            return countries.sorted {
                if $0.code == "UA" { return true }
                if $1.code == "UA" { return false }

                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        } catch {
            assertionFailure("Failed to load Country.json: \(error)")
            return []
        }
    }
}
