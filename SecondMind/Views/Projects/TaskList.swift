import SwiftUI
import SwiftData

struct TaskList: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions

    // Se mantiene el parámetro como lo usas en ProjectDetall
    @Bindable var editableProject: Project

    @StateObject private var viewModel: TaskListViewModel

    // ✅ init compatible: NO creamos ModelContext() aquí
    init(editableProject: Project) {
        self._editableProject = Bindable(wrappedValue: editableProject)
        _viewModel = StateObject(wrappedValue: TaskListViewModel(project: editableProject))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Tareas del proyecto")
                    .font(.headline)
                    .foregroundColor(Color.taskButtonColor)
                Text("\(viewModel.filteredTasks.count)").bold()
                Spacer()
                NavigationLink(destination: ProjectTaskView(project: viewModel.editableProject)) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.taskButtonColor)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.taskButtonColor)
                    }
                }
            }

            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)

            // Contenido
            if viewModel.filteredTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.text.page")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 90)
                        .foregroundColor(Color.taskButtonColor.opacity(0.7))

                    Text("No hay tareas disponibles.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(20)
            } else if viewModel.filteredTasks.count == 1 {
                ForEach(viewModel.filteredTasks.prefix(1)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                }
            } else {
                ForEach(viewModel.filteredTasks.prefix(2)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .onAppear {
            // ✅ Inyectamos dependencias reales aquí (sin reasignar el StateObject)
            viewModel.updateDependencies(context: context, utilFunctions: utilFunctions)
        }
    }

    // MARK: - Fila
    private func taskRow(task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 22))
                .foregroundColor(Color.taskButtonColor)

            Text(task.title)
                .font(.system(size: 17))
                .foregroundColor(.primary)

            Spacer()

            Button {
                viewModel.deleteTask(task)
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 21))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .modifier(TaskCardModifier())
    }
}
