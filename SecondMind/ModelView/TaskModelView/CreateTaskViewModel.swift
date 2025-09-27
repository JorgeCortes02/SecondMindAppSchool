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

    func updateProjectSelection(_ newProject: Project?) {
        if newTask.event == nil {
            newTask.endDate = newProject?.endDate
        }
        if let safeProject = newProject, let context {
            events = HomeApi.downdloadEventsFromProject(project: safeProject, context: context)
        } else {
            events = []
        }
    }

    func updateEventSelection(_ newEvent: Event?) {
        newTask.project = newEvent?.project
        newTask.endDate = newEvent?.endDate
    }

    func saveTask(dismiss: DismissAction) {
        guard let context else { return }
        if newTask.title.isEmpty {
            isIncompleteTask = true
        } else {
            isIncompleteTask = false
            context.insert(newTask)
            if let project = newTask.project {
                project.tasks.append(newTask)
            }
            do {
                NSLog("🟢 Creando nota con token: %@", CurrentUser.token())
                print("🟢 Nota.token guardado: \(newTask.token)")
                try context.save()
                Task{
                    
                    await SyncManagerUpload.shared.uploadTask(task: newTask)
                    
                }
               
            } catch {
                print("❌ Error al guardar tarea: \(error)")
            }
            dismiss()
        }
    }
}
