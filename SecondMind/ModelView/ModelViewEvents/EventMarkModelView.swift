import Foundation
import SwiftData
import SwiftUI

public class EventMarkModelView: BaseEventViewModel {
    
    @Published var events: [Event] = []
    @Published var selectedTab: Int = 0
    
    var context: ModelContext?
    
    init(context: ModelContext? = nil) {
        self.context = context
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Cargar eventos globales (agendados o finalizados)
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
    private func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }
}
