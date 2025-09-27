//
//  HomeFilesModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 27/9/25.
//

import Foundation
import SwiftUI
import SwiftData

public class HomeFilesModelView: ObservableObject {
    
    @Published var todayEvents: [Event] = []
    @Published var todayTask: [TaskItem] = []
    @Published var projectNotes: [NoteItem] = []
    
    // 👇 Nuevo: mensaje de actualización
    @Published var updateMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private var context: ModelContext?
    
    init(context: ModelContext? = nil) {
        self.context = context
    }
    
    func setContext(context: ModelContext) {
        self.context = context
        Task {
            await refreshAll()
        }
    }
    
    // 🔹 Refresca todos los datos desde la API y actualiza CoreData
    @MainActor
    func refreshAll() async {
        guard let context else { return }
        isLoading = true
        updateMessage = nil
        
        await SyncManagerDownload.shared.syncAll(context: context)
        
        downdloadTodayTasks()
        downdloadTodayEvents()
        
        isLoading = false
        
        withAnimation {
            updateMessage = "✅ Datos actualizados correctamente"
        }
        
        // Ocultar mensaje tras 2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.updateMessage = nil
            }
        }
    }
    
    // MARK: – Tasks
    func downdloadTodayTasks() {
        if let context = self.context {
            todayTask = HomeApi.fetchTodayTasks(context: context)
        }
    }
    
    // MARK: – Events
    func downdloadTodayEvents() {
        if let context = self.context {
            todayEvents = HomeApi.fetchTodayEvents(context: context)
        }
    }
    
    func deletepastEvents(utilFunctions: generalFunctions) {
        if let context = self.context {
            utilFunctions.pastEvent(eventList: &todayEvents, context: context)
        }
    }
    
    // MARK: – Notes
    func loadNotesForProject(_ project: Project) {
        projectNotes = project.notes.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func loadNotesForEvent(_ event: Event) {
        projectNotes = event.notes.sorted { $0.updatedAt > $1.updatedAt }
    }
}
