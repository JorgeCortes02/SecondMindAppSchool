//
//  UserDefalutLogin.swift
//  SecondMind
//
//  Created by Jorge Cortés on 16/9/25.
//
import SwiftUI

class UserSession {
    private let userKey = "user"
    
    private var userDict: [String: Any] {
        get { UserDefaults.standard.dictionary(forKey: userKey) ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: userKey) }
    }
    
    var id: Int {
        get { userDict["id"] as? Int ?? 0 }
        set {
            var dict = userDict
            dict["id"] = newValue
            userDict = dict
        }
    }
    
    var name: String {
        get { userDict["name"] as? String ?? "" }
        set {
            var dict = userDict
            dict["name"] = newValue
            userDict = dict
        }
    }
    
    var email: String {
        get { userDict["email"] as? String ?? "" }
        set {
            var dict = userDict
            dict["email"] = newValue
            userDict = dict
        }
    }
    
    var service: String {
        get { userDict["service"] as? String ?? "" }
        set {
            var dict = userDict
            dict["service"] = newValue
            userDict = dict
        }
    }
    
    func update( name: String, enteremail: String? = nil) {
      
        self.name = name
        
        if let newmail = enteremail{
            
            self.email = newmail
        }
        self.email = email
       
    }
    
    func setData (id: Int, name: String, enteremail: String, service: String) {
        
        self.id = id
        self.name = name
        self.email = enteremail
        self.service = service
    
    
    }
}
