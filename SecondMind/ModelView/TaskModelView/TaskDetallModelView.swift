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

    // 🔹 Control de bloqueo de pickers
    @Published var lockProject: Bool = false
    @Published var lockEvent: Bool = false

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
            Task {
                await SyncManagerUpload.shared.uploadTask(task: editableTask)
            }
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

                Task {
                    await SyncManagerUpload.shared.uploadTask(task: realTask)
                }
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
            Task {
                await SyncManagerUpload.shared.deleteTask(task: editableTask)
            }
            dismiss()
        } catch {
            print("❌ Error al borrar: \(error)")
        }
    }

    // MARK: - 🔹 Manejo de selección de proyecto
    func updateProjectSelection(_ newProject: Project?) {
        guard !lockProject else { return } // Evita cambios si está bloqueado

        editableTask.project = newProject

        if let safeProject = newProject {
            events = HomeApi.downdloadEventsFromProject(project: safeProject, context: context)
        } else {
            // Si se quita el proyecto, mostramos todos los eventos
            events = HomeApi.downdloadEventsFrom(context: context)
        }

        // Si el evento actual no pertenece al nuevo proyecto → eliminarlo
        if let currentEvent = editableTask.event,
           let project = newProject,
           currentEvent.project?.id != project.id {
            editableTask.event = nil
        }
    }

    // MARK: - 🔹 Manejo de selección de evento
    func updateEventSelection(_ newEvent: Event?) {
        guard let event = newEvent else {
            // Si se quita el evento, desbloqueamos el picker de proyecto
            editableTask.event = nil
            editableTask.endDate = nil
            lockProject = false
            return
        }

        // Asignamos el evento
        editableTask.event = event
        editableTask.endDate = event.endDate

        if let eventProject = event.project {
            // Si el evento tiene proyecto, lo asignamos
            editableTask.project = eventProject
        }

        // 🔒 Siempre que haya evento, bloqueamos el picker de proyecto
        lockProject = true
    }
}
