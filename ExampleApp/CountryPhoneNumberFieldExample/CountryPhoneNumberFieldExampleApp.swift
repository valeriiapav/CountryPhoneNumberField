//
//  CountryPhoneNumberFieldExampleApp.swift
//  CountryPhoneNumberFieldExample
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import SwiftUI
import UIKit

@main
struct CountryPhoneNumberFieldExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ViewControllerRepresentable()
                .ignoresSafeArea()
        }
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ViewController {
        ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
    }
}
