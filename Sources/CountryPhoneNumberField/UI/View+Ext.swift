//
//  View+Ext.swift
//  CountryPhoneNumberField
//
//  Created by Valeriia Pavlykovych on 12.05.2026.
//

import Foundation
import UIKit

extension UIView {

    var parentViewController: UIViewController? {
        sequence(first: self.next) { $0?.next }
            .first { $0 is UIViewController } as? UIViewController
    }
}
