//
//  TaskDetallModelView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 24/9/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class TaskDetailViewModel: ObservableObject {
    @Published var editableTask: TaskItem
    @Published var events: [Event] = []
    @Published var projects: [Project] = []
    @Published var isEditing: Bool = false
    @Published var showDatePicker: Bool = false
    @Published var isIncompleteTask: Bool = false

    private var context: ModelContext

    init(task: TaskItem, context: ModelContext) {
        self.editableTask = task
        self.context = context
        loadData()
    }

    func loadData() {
        events = HomeApi.downdloadEventsFrom(context: context)
        projects = HomeApi.downdloadProjectsFrom(context: context)
    }

    func toggleEdit() {
        isEditing = true
    }

    func markAsCompleted(dismiss: DismissAction) {
        editableTask.completeDate = Date()
        editableTask.status = .off
        do {
            try context.save()
            dismiss()
        } catch {
            print("❌ Error al marcar completada: \(error)")
        }
    }

    func saveChanges() {
        do {
            let descriptor = FetchDescriptor<TaskItem>()
            let tasks = try context.fetch(descriptor)

            if let realTask = tasks.first(where: { $0.id == editableTask.id }) {
                realTask.title = editableTask.title
                realTask.descriptionTask = editableTask.descriptionTask
                realTask.endDate = editableTask.endDate
                realTask.project = editableTask.project
                realTask.event = editableTask.event
                realTask.status = editableTask.status
                realTask.completeDate = editableTask.completeDate

                try context.save()
            }
            isEditing = false
        } catch {
            print("❌ Error al guardar: \(error)")
        }
    }

    func deleteTask(dismiss: DismissAction) {
        do {
            try context.delete(editableTask)
            try context.save()
            dismiss()
        } catch {
            print("❌ Error al borrar: \(error)")
        }
    }

    func updateProjectSelection(_ newProject: Project?) {
        if editableTask.event == nil {
            editableTask.endDate = newProject?.endDate ?? nil
        }
        if let safeProject = newProject {
            events = HomeApi.downdloadEventsFromProject(project: safeProject, context: context)
        } else {
            events = []
        }
    }

    func updateEventSelection(_ newEvent: Event?) {
        editableTask.project = newEvent?.project
        editableTask.endDate = newEvent?.endDate
    }
}
