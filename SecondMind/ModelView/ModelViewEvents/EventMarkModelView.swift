import Foundation
import SwiftData
import SwiftUI

public class EventMarkModelView: BaseEventViewModel {
    
    
    @Published var events: [Event] = []
    @Published var selectedTab: Int = 0
    @Published var selectedData: Date = Date()
    var context: ModelContext?
    
    init(context: ModelContext? = nil) {
        self.context = context
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }

    
    // MARK: - Cargar eventos filtrados por proyecto
    func loadEvents() {
        guard let context else { return }
        
        if selectedTab == 0 {
            // Solo los eventos futuros del proyecto
            events = HomeApi.downdloadEventsDate(date: selectedData, context: context)
               
            events = sortedArrayEvent(events)
        
        } else {
            // Solo los eventos finalizados del proyecto
            events = HomeApi.eventsLastWeek(context: context)
               
            events = sortedArrayEvent(events).reversed()
        }
    }
    
    // MARK: - Ordenación
    private func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }
}
