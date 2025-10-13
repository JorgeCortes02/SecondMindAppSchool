import SwiftUI
import SwiftData

@MainActor
class CreateProjectViewModel: ObservableObject {
    @Published var newProject = Project(title: "", endDate: nil, description: "")
    @Published var isIncompleteTitle = false

    private var context: ModelContext?
    private var utilFunctions: generalFunctions?

    init(context: ModelContext? = nil, utilFunctions: generalFunctions? = nil) {
        self.context = context
        self.utilFunctions = utilFunctions
    }

    func setContext(context: ModelContext, util: generalFunctions) {
        self.context = context
        self.utilFunctions = util
    }

    func clearDate() {
        newProject.endDate = nil
    }

    func saveProject(dismiss: DismissAction) {
        guard let context else {
            print("⚠️ ModelContext no disponible. Se debe inyectar antes de guardar.")
            return
        }

        if newProject.title.isEmpty {
            isIncompleteTitle = true
            return
        }

        context.insert(newProject)
        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadProject(project: newProject)
            }
            dismiss()
        } catch {
            print("❌ Error al guardar proyecto: \(error)")
        }
    }
}
