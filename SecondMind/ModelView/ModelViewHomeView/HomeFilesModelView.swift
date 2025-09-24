//
//  HomeFilesModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 5/9/25.
//
import Foundation
import SwiftUI
import SwiftData

public class HomeFilesModelView: ObservableObject {
    
    @Published var todayEvents: [Event] = []
    @Published var todayTask: [TaskItem] = []
    @Published var projectNotes: [NoteItem] = []   // 👈 añadimos notas del proyecto
    
    @EnvironmentObject var utilFunctions: generalFunctions
    
    private var context: ModelContext?
    
    init(context: ModelContext? = nil) {
        self.context = context
    }
    
    func setContext(context: ModelContext) {
        self.context = context
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
    
    func deletepastEvents() {
        if let context = self.context {
            utilFunctions.pastEvent(eventList: &todayEvents, context: context)
        }
    }
    
    // MARK: – Notes
    func loadNotesForProject(_ project: Project) {
        // directamente desde la relación del modelo
        projectNotes = project.notes.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func loadNotesForEvent(_ event: Event) {
        projectNotes = event.notes.sorted { $0.updatedAt > $1.updatedAt }
    }
}
