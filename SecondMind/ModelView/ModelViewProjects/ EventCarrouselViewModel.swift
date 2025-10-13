//
//   EventCarrouselViewModel.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/10/25.
//

import SwiftUI

@MainActor
class EventCarrouselViewModel: ObservableObject {
    @Published var filteredEvents: [Event] = []
    
    func loadEvents(for project: Project) {
        filteredEvents = project.events
            .filter { $0.status == .on }
            .sorted { $0.endDate < $1.endDate }
    }
    
    func formattedDate(_ date: Date, using util: generalFunctions) -> String {
        util.formattedDateAndHour(date)
    }
}
