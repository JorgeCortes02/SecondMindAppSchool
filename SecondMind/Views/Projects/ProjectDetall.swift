import SwiftUI
import SwiftData

struct ProjectDetall: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions
    
    @StateObject private var viewModel: ProjectDetallViewModel
    
    private let lavenderBackground = Color(red: 242/255, green: 238/255, blue: 250/255)
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)

    init(editableProject: Project) {
        _viewModel = StateObject(wrappedValue: ProjectDetallViewModel(project: editableProject))
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                   
                    Header()
                    VStack(spacing: 26) {
                       
                        headerSection
                        Divider().padding(.horizontal, 20)
                        statsSection
                        Divider().padding(.horizontal, 20)
                        buttonsSection
                        Divider().padding(.horizontal, 20)
                        descriptionSection
                        carrouselsSection
                    }
                    .padding(.vertical, sizeClass == .regular ? 34 : 24)
                    .padding(.horizontal, sizeClass == .regular ? 40 : 22)
                    .frame(maxWidth: sizeClass == .regular ? 800 : .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(purpleAccent.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, sizeClass == .regular ? 16 : 10)
                    .padding(.top, 12)
                }
            }
        }
        .onAppear {
            viewModel.setDependencies(context: context, dismiss: dismiss, utilFunctions: utilFunctions)
        }
       
    }

    // MARK: - Secciones de la vista

    // Título del proyecto + botones superiores
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            
            Image(systemName: "folder.fill")
                .font(.system(size: sizeClass == .regular ? 28 : 22, weight: .semibold))
                .foregroundColor(purpleAccent)

            Text(viewModel.editableProject.title)
                .font(.system(size: sizeClass == .regular ? 24 : 20, weight: .bold))
                .foregroundColor(purpleAccent)
                .lineLimit(1)

            Spacer()

            HStack(spacing: 18) {
                Button(action: { viewModel.toggleEditing() }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }

                Button(action: { viewModel.markAsCompleted() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // Sección de estadísticas
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            
            statRow(title: "Estado", value: viewModel.editableProject.status == .on ? "Activo" : "Finalizado", color: viewModel.editableProject.status == .on ? .green : .red)
            
            if let endDate = viewModel.editableProject.endDate {
                statRow(title: "Fecha fin", value: utilFunctions.formattedDateShort(endDate), color: .eventButtonColor)
            } else {
                statRow(title: "Fecha fin", value: "Sin fecha", color: .secondary)
            }

            VStack(alignment: .leading, spacing: 14) {
                statSmall(icon: "checkmark.circle.fill", text: "\(viewModel.editableProject.tasks.filter { $0.status == .on }.count) tareas activas", color: .taskButtonColor)
                statSmall(icon: "calendar", text: "\(viewModel.editableProject.events.filter { $0.status == .on }.count) eventos activos", color: .eventButtonColor)
            }
        }
    }

    // Botones "Nueva tarea", "Nuevo evento", "Nueva nota"
    private var buttonsSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                Button(action: { viewModel.showAddTaskView = true }) {
                    Label("Nueva Tarea", systemImage: "checkmark.circle")
                }
                .sheet(isPresented: $viewModel.showAddTaskView) {
                    CreateTask(project: viewModel.editableProject)
                }
                .buttonStyle(RoundedButtonStyle(backgroundColor: .taskButtonColor))

                Button(action: { viewModel.showAddEventView = true }) {
                    Label("Nuevo Evento", systemImage: "calendar.badge.plus")
                }
                .sheet(isPresented: $viewModel.showAddEventView) {
                    CreateEvent(project: viewModel.editableProject)
                }
                .buttonStyle(RoundedButtonStyle(backgroundColor: .eventButtonColor))
            }

            NavigationLink(destination: NoteDetailView(project: viewModel.editableProject)) {
                Label("Nueva nota", systemImage: "plus")
            }
            .buttonStyle(RoundedButtonStyle(backgroundColor: Color.noteBlue))
        }
    }

    // Descripción del proyecto
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Descripción")
                .font(.headline)
                .foregroundStyle(purpleAccent)

            if viewModel.isEditing {
                TextEditor(text: Binding(
                    get: { viewModel.editableProject.descriptionProject ?? "" },
                    set: { viewModel.editableProject.descriptionProject = $0 }
                ))
                .frame(minHeight: 110)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
            } else {
                Text(viewModel.editableProject.descriptionProject?.isEmpty ?? true ? "No hay descripción." : viewModel.editableProject.descriptionProject!)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(textFieldBackground)
                    .cornerRadius(14)
            }
        }
    }

    // Carruseles inferiores
    private var carrouselsSection: some View {
        VStack(spacing: 24) {
            TaskList(editableProject: viewModel.editableProject)
            NotesCarrousel(editableProject: viewModel.editableProject)
            EventCarrousel(editableProject: viewModel.editableProject)
        }
    }

    // MARK: - Utilidades visuales internas

    private func statRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text("\(title):")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(color)
            Spacer()
        }
    }

    private func statSmall(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}
