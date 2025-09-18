//
//  AppDelegate.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/9/25.
//

import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
