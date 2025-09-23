//
//  EventMarkProjectDetallModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 19/9/25.
//

import Foundation
import SwiftData
import SwiftUI

public class TaskMarkProjectDetallModelView: ObservableObject {
    
    @Published var tasks: [TaskItem] = []
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
    
    func extractDayTasks(date : Date) -> [TaskItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        var tasks: [TaskItem] = []
        
        if let project = project {
        
            return project.tasks.filter { task in
                   if let endDate = task.endDate {
                       return Calendar.current.isDate(endDate, inSameDayAs: date) && task.status == .on
                   } else {
                       return false
                   }
               }
          
        }
        
        return tasks
        
        
    }
    
    func extractNoDateTasks() -> [TaskItem] {
        var tasks: [TaskItem] = []
        
        if let project = project {
            
            tasks = project.tasks.filter { $0.endDate == nil && $0.status == .on }
            
        }
        return tasks
    }
    
    func extractOffTasks() -> [TaskItem] {
       
        var tasks: [TaskItem] = []
        
        if let project = project {
        
            tasks =  project.tasks.filter{
                   
               $0.status == .off
            }
        
          
        }
        
        return tasks
        
        
    }
    
     func loadEvents(selectedData: Date? = nil) {
        switch selectedTab {
        case 0:
     
                tasks = extractNoDateTasks()
            break;
        case 1:
            
            if let selectedData {
                tasks = extractDayTasks(date: selectedData)
                
            }
         
            break;
        case 2:
            tasks = extractOffTasks()
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
    

