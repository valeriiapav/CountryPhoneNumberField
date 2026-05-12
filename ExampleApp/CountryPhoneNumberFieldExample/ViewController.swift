//
//  ViewController.swift
//  CountryPhoneNumberFieldExample
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import UIKit
import CountryPhoneNumberField

final class ViewController: UIViewController {

    private let phoneField = CountryPhoneNumberField(
        configuration: .init(
            countryTitle: "Country",
            phoneTitle: "Phone number",
            phonePlaceholder: "Enter phone number"
        )
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(phoneField)
        phoneField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            phoneField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            phoneField.heightAnchor.constraint(equalToConstant: 72)
        ])

        phoneField.didValidatePhone = { isValid in
            print("VALID:", isValid)
        }
    }
}
