import SwiftUI
import SwiftData

@MainActor
class TaskListViewModel: ObservableObject {
    @Bindable var editableProject: Project

    // Se inyectan después (NO se crean aquí)
    private var context: ModelContext?
    private var utilFunctions: generalFunctions?

    init(project: Project, context: ModelContext? = nil, utilFunctions: generalFunctions? = nil) {
        self._editableProject = Bindable(wrappedValue: project)
        self.context = context
        self.utilFunctions = utilFunctions
    }

    // Llamar en .onAppear desde la View
    func updateDependencies(context: ModelContext, utilFunctions: generalFunctions) {
        self.context = context
        self.utilFunctions = utilFunctions
    }

    // Filtrado + orden
    var filteredTasks: [TaskItem] {
        editableProject.tasks
            .filter { $0.status == .on }
            .sorted {
                switch ($0.endDate, $1.endDate) {
                case let (a?, b?): return a < b
                case (_?, nil):   return true
                case (nil, _?):   return false
                case (nil, nil):  return false
                }
            }
    }

    func deleteTask(_ task: TaskItem) {
        task.status = .off
        task.completeDate = Date()

        guard let context else {
            print("⚠️ ModelContext no inyectado. Llama updateDependencies en .onAppear.")
            return
        }
        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadTask(task: task)
            }
        } catch {
            print("❌ Error al guardar cambios: \(error)")
        }
    }
}
