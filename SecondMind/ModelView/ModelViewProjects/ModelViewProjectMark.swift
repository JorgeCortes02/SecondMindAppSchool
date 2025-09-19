//
//  ProjectMarkViewModel.swift
//  SecondMind
//
//  Created by Jorge Cortés on 20/9/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class ProjectMarkViewModel: ObservableObject {
    @Published var readyToShowTasks: Bool = false
    @Published var showAddProjectView: Bool = false
    @Published var selectedTab: Int = 0
    @Published var projectList: [Project] = []
    
    
    private var context: ModelContext?
    private var utilFunctions: generalFunctions?
    
    @Published var eventsForDay: [Event] = []
    @Published var passedEvents: [Event] = []
    
    
    
    func setContext(_ context: ModelContext, util: generalFunctions, project : Project) {
        self.context = context
        self.utilFunctions = util
       
    }
    
   
    
    
    /// Cargar proyectos según pestaña seleccionada
    func loadProjects() {
        guard let context else { return }
        
        if selectedTab == 1 {
            projectList = HomeApi.downloadOffProjects(context: context)
        } else {
            projectList = HomeApi.downloadOnProjects(context: context)
        }
    }
    
    /// Texto del próximo evento
    func nextEventText(for events: [Event]) -> String {
        guard let utilFunctions else { return "—" }
        let today = Date()
        let futureEvents = events.filter { $0.endDate > today }
        if let firstEvent = futureEvents.min(by: { $0.endDate < $1.endDate }) {
            return utilFunctions.formattedDateAndHour(firstEvent.endDate)
        }
        return "No hay eventos"
    }
}
