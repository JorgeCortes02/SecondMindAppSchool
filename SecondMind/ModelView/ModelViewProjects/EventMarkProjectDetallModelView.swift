import Foundation
import SwiftData
import SwiftUI

public class EventMarkProjectDetallModelView: BaseEventViewModel {
    
    @Published var events: [Event] = []
    @Published var selectedTab: Int = 0
    @Published var readyToShowTasks: Bool = false
    @Published var selectedData: Date = Date()
    
    var project: Project?
    var context: ModelContext?
    
    init(context: ModelContext? = nil, project: Project? = nil) {
        self.context = context
        self.project = project
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func setParameters(context: ModelContext, project: Project) {
        self.context = context
        self.project = project
    }
    
    // MARK: - Extraer eventos del día (activos)
    private func extractDayEvents() -> [Event] {
        guard let project = project else { return [] }
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedData)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return project.events.filter {
            $0.endDate >= startOfDay && $0.endDate < endOfDay && $0.status == .on
        }
    }
    
    // MARK: - Extraer eventos finalizados
    private func extractOffEvents() -> [Event] {
        guard let project = project else { return [] }
        return project.events.filter { $0.status == .off }
    }
    
    // MARK: - Cargar eventos según pestaña y fecha seleccionada
    func loadEvents() {
        switch selectedTab {
        case 0:
            
                events = extractDayEvents()
            
        case 1:
            events = extractOffEvents()
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
