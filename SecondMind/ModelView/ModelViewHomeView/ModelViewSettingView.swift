//
//  ModelViewSettingView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 15/9/25.
//

import SwiftUI
import SwiftData
import Foundation

public class ModelViewSettingView: ObservableObject {
    
    
    // Campos
    @Published  var email = ""
    @Published  var newpassword = ""
    @Published  var confirmPassword = ""
    @Published  var oldPassword = ""
    @Published  var name = ""
    @Published  var google_id = ""
    @Published  var service = ""
    private var context: ModelContext?
    
    init(context: ModelContext? = nil){
        if let savedUser = UserDefaults.standard.dictionary(forKey: "user") {
            if let savedName = savedUser["name"] as? String { name = savedName }
            if let savedEmail = savedUser["email"] as? String { email = savedEmail }
            if let savedService = savedUser["service"] as? String { service = savedService }
            if let savedGoogleId = savedUser["id"] as? String { google_id = savedGoogleId }
        }
    
        self.context = context
    }


    
    func setContext(context: ModelContext){
        
        self.context = context
    }
    
}
