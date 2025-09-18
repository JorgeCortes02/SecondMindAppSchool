//
//  CreateEventModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 31/8/25.
//


import Foundation
import SwiftUI
import SwiftData



public class CreateEventModelView: ObservableObject {
    
    
    @Published var projects : [Project] = []
    @Published var isIncompleteTask: Bool = false
    
    
    private var context : ModelContext?

    
    
    init(context: ModelContext? = nil){
        
        self.context = context
        
    }
    
    
    func setContext (context: ModelContext) {
        self.context = context
    }
    
    
    func loadProjects(){
        
        if let context = self.context {
            projects = HomeApi.downdloadProjectsFrom(context: context)
        }
     
    }
    
   
    
 
    
    
}
