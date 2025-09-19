//
//  EventMarkProjectDetallModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 19/9/25.
//

import Foundation
import SwiftData
import SwiftUI

public class EventMarkProjectDetallModelView: ObservableObject {
    
    @Published var events: [Event] = []
    @Published var selectedTab: Int = 0
    private var project : Project? = nil
    private var context: ModelContext?
    @Published var readyToShowTasks : Bool = false
    init(context: ModelContext? = nil, project : Project? = nil){
        
        self.context = context
        self.project = project
    }
    
    func setParameters(context: ModelContext, project: Project) {
        self.context = context
        self.project = project
    }
    
    func extractDayProjects(date : Date) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        var events: [Event] = []
        
        if let project = project {
        
            events =  project.events.filter{
                   
               $0.endDate >= startOfDay && $0.endDate < endOfDay
               && $0.status == .on
            }
        
          
        }
        
        return events
        
        
    }
    
    func extractOffProjects() -> [Event] {
       
        var events: [Event] = []
        
        if let project = project {
        
            events =  project.events.filter{
                   
               $0.status == .on
            }
        
          
        }
        
        return events
        
        
    }
    
     func loadEvents(selectedData: Date? = nil) {
        switch selectedTab {
        case 0:
            if let selectedData {
                events = extractDayProjects(date: selectedData)
            }
            break;
        case 1:
          events = extractOffProjects()
        default:
            break
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.readyToShowTasks = true
            }
        }
    }

        
    }
    

