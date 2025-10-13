import Foundation
import SwiftData
import SwiftUI

@MainActor
class CreateTaskViewModel: ObservableObject {
    @Published var newTask: TaskItem
    @Published var events: [Event] = []
    @Published var projects: [Project] = []
    @Published var isIncompleteTask: Bool = false
    @Published var showDatePicker: Bool = false
    
    // 🔹 Control de bloqueo
    @Published var lockProject: Bool = false
    @Published var lockEvent: Bool = false

    private var context: ModelContext?

    init(project: Project? = nil) {
        self.newTask = TaskItem(
            title: "",
            endDate: nil,
            project: project,
            event: nil,
            status: .on,
            descriptionTask: ""
        )

        if let project {
            self.newTask.project = project
            self.lockProject = true
        }
    }

    func configure(context: ModelContext) {
        self.context = context
        loadData()
    }

    func loadData() {
        guard let context else { return }
        events = HomeApi.downdloadEventsFrom(context: context)
        projects = HomeApi.downdloadProjectsFrom(context: context)
    }

    // MARK: - 🔹 Proyecto seleccionado
    func updateProjectSelection(_ newProject: Project?) {
        guard !lockProject else { return } // Evita cambios si está bloqueado

        newTask.project = newProject

        if let safeProject = newProject, let context {
            events = HomeApi.downdloadEventsFromProject(project: safeProject, context: context)
        } else if let context {
            events = HomeApi.downdloadEventsFrom(context: context)
        } else {
            events = []
        }

        // Si el evento actual no pertenece al nuevo proyecto → limpiarlo
        if let currentEvent = newTask.event,
           let project = newProject,
           currentEvent.project?.id != project.id {
            newTask.event = nil
        }
    }

    // MARK: - 🔹 Evento seleccionado
    func updateEventSelection(_ newEvent: Event?) {
        guard let event = newEvent else {
            // Si se quita el evento, desbloqueamos el proyecto
            newTask.event = nil
            newTask.endDate = nil
            lockProject = false
            return
        }

        newTask.event = event
        newTask.endDate = event.endDate

        if let eventProject = event.project {
            newTask.project = eventProject
        }

        // 🔒 Siempre bloqueamos el picker de proyecto si hay evento
        lockProject = true
    }

    // MARK: - Guardar tarea
    func saveTask(dismiss: DismissAction) {
        guard let context else { return }

        if newTask.title.isEmpty {
            isIncompleteTask = true
            return
        }

        isIncompleteTask = false
        context.insert(newTask)

        if let project = newTask.project {
            project.tasks.append(newTask)
        }

        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadTask(task: newTask)
            }
            dismiss()
        } catch {
            print("❌ Error al guardar tarea: \(error)")
        }
    }
}
