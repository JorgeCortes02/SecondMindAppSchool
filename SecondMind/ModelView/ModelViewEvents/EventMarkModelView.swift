//
//  EventMarkModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 31/8/25.
//

import Foundation
import SwiftData
import SwiftUI

public class EventMarkModelView: ObservableObject {
    
    
    @Published var events: [Event] = []
    @EnvironmentObject var  utilFunctions : generalFunctions
    private var context: ModelContext?
    
    //EventMark
    
    @Published var selectedTab : Int = 0
    
       
    
    init(context: ModelContext? = nil) {
           self.context = context
       }
    
    func setContext(context : ModelContext){
        self.context = context
    }
    
    func loadEvents(date : Date? = nil){
        
        if let date {
         
       
                if let context {
                
                    events = HomeApi.downdloadEventsDate(date: date, context: context)
                        .filter { $0.status.rawValue == "on" }
                    events = sortedArrayEvent(events)
                    
                }
          
         
        }else{
            
            if let context {
                events = HomeApi.eventsLastWeek(context: context)
            }
            
        }
     
        
        
    }
    
    
    func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }
    
}
