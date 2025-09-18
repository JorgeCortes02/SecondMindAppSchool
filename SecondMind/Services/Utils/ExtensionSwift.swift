//
//  ExtensionSwift.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/9/25.
//

import SwiftUI

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}
