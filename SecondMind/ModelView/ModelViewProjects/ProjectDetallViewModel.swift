import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ProjectDetallViewModel: ObservableObject {
    // Referencias
    @Published var editableProject: Project

    // Estados UI
    @Published var isEditing: Bool = false
    @Published var showDatePicker: Bool = false
    @Published var showAddTaskView: Bool = false
    @Published var showAddEventView: Bool = false

    // Entornos
    private var context: ModelContext?
    private var dismiss: DismissAction?
    private var utilFunctions: generalFunctions?

    init(project: Project) {
        self.editableProject = project
    }

    func setDependencies(context: ModelContext, dismiss: DismissAction, utilFunctions: generalFunctions) {
        self.context = context
        self.dismiss = dismiss
        self.utilFunctions = utilFunctions
    }

    func toggleEditing() {
        isEditing.toggle()
    }

    func saveProject() {
        guard let context else { return }
        do {
            let descriptor = FetchDescriptor<Project>()
            let projects = try context.fetch(descriptor)
            if let realProject = projects.first(where: { $0.id == editableProject.id }) {
                realProject.title = editableProject.title
                realProject.descriptionProject = editableProject.descriptionProject
                realProject.endDate = editableProject.endDate
                try context.save()
                Task {
                    await SyncManagerUpload.shared.uploadProject(project: realProject)
                }
            }
            isEditing = false
        } catch {
            print("❌ Error al guardar proyecto: \(error)")
        }
    }

    func markAsCompleted() {
        guard let context else { return }
        editableProject.endDate = Date()
        editableProject.status = .off
        
        for event in editableProject.events {
            event.status = .off
        }
        
        
        
        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadProject(project: editableProject)
                for event in editableProject.events {
                    await SyncManagerUpload.shared.uploadEvent(event: event)
                }
            }
            dismiss?()
        } catch {
            print("❌ Error al marcar completado: \(error)")
        }
    }
}
