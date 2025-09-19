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
    private var context: ModelContext?
    
    /// Pestaña seleccionada → 0 = Agendados, 1 = Finalizados
    @Published var selectedTab: Int = 0
    
    init(context: ModelContext? = nil) {
        self.context = context
    }
    
    func setContext(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Cargar eventos globales
    func loadEvents(date: Date? = nil) {
        guard let context else { return }
        
        if let date {
            // Eventos agendados (estado "on")
            events = HomeApi.downdloadEventsDate(date: date, context: context)
                .filter { $0.status.rawValue == "on" }
            events = sortedArrayEvent(events)
        } else {
            // Eventos finalizados (última semana)
            events = HomeApi.eventsLastWeek(context: context)
        }
    }
    
    // MARK: - Cargar eventos filtrados por proyecto
    func loadEvents(for project: Project, date: Date? = nil) {
        guard let context else { return }
        
        if let date {
            // Solo los eventos futuros del proyecto
            events = HomeApi.downdloadEventsDate(date: date, context: context)
                .filter { $0.project == project && $0.status.rawValue == "on" }
            events = sortedArrayEvent(events)
        } else {
            // Solo los eventos finalizados del proyecto
            events = HomeApi.eventsLastWeek(context: context)
                .filter { $0.project == project }
            events = sortedArrayEvent(events).reversed()
        }
    }
    
    // MARK: - Ordenación
    func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }
}
