import SwiftUI
import SwiftData

struct ProjectDetall: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject private var viewModel: ProjectDetallViewModel

    private let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)

    init(editableProject: Project) {
        _viewModel = StateObject(wrappedValue: ProjectDetallViewModel(project: editableProject))
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 10) {
                    Header()
                        .frame(height: 40)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    Spacer()

                    // ✅ Contenedor general que adapta formato según dispositivo
                    Group {
                        if sizeClass == .regular {
                            // 💻 iPad: tarjeta centrada
                            contentView
                                .frame(maxWidth: 800)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 24)
                                .background(Color.white)
                                .cornerRadius(40)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                                .padding(.top, 10)
                        } else {
                            // 📱 iPhone: vista original sin cambios
                            contentView
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                                .cornerRadius(40)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color.purple, lineWidth: 0.5)
                                )
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.setDependencies(context: context, dismiss: dismiss, utilFunctions: utilFunctions)
        }
    }

    // MARK: - Subvista: contenido principal
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- BLOQUE SUPERIOR LAVANDA ---
            VStack {
                HStack {
                    if viewModel.isEditing {
                        TextField("Título", text: $viewModel.editableProject.title)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(textFieldBackground))
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                    } else {
                        Image(systemName: "folder")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.taskButtonColor)
                            .padding(.bottom, 4)

                        Text(viewModel.editableProject.title)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.taskButtonColor)
                            .padding(.bottom, 4)
                            .lineLimit(1)
                            .toolbar {
                                ToolbarItemGroup(placement: .topBarTrailing) {
                                    Button(action: { viewModel.toggleEditing() }) {
                                        Image(systemName: "pencil")
                                    }
                                    Button(action: {}) {
                                        Image(systemName: "trash")
                                    }
                                }
                            }
                    }
                }

                HStack {
                    Text("Estado:")
                        .font(.headline)
                        .foregroundColor(Color.taskButtonColor)

                    if viewModel.editableProject.status == .on {
                        Text("Activo")
                            .foregroundStyle(Color(red: 0/255, green: 100/255, blue: 0/255))
                            .bold()
                    } else {
                        Text("Finalizado")
                            .foregroundStyle(Color(red: 153/255, green: 0/255, blue: 51/255))
                    }
                }

                VStack {
                    HStack(spacing: 24) {
                        Label {
                            Text("Tareas: \(viewModel.editableProject.tasks.filter { $0.status == .on }.count)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primaryText)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.taskButtonColor)
                        }

                        Label {
                            Text("Eventos: \(viewModel.editableProject.events.filter { $0.status == .on }.count)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primaryText)
                        } icon: {
                            Image(systemName: "calendar")
                                .font(.system(size: 18))
                                .foregroundColor(.eventButtonColor)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)

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
                    .frame(maxWidth: .infinity, alignment: .center)

                    NavigationLink(destination: NoteDetailView(project: viewModel.editableProject)) {
                        Label("Nueva nota", systemImage: "plus")
                    }
                    .buttonStyle(RoundedButtonStyle(backgroundColor: .blue))
                }
                .padding(.top, 10)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 228/255, green: 214/255, blue: 244/255))
            .cornerRadius(30, corners: [.topLeft, .topRight])

            // --- BLOQUE INFERIOR BLANCO ---
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Text("Fecha fin:")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    if let date = viewModel.editableProject.endDate {
                        Text(utilFunctions.formattedDateShort(date))
                            .font(.headline)
                            .padding(.bottom, 4)
                            .foregroundColor(Color.eventButtonColor)
                    } else {
                        Text("Sin fecha")
                            .font(.body)
                            .foregroundColor(.secondary).padding(.bottom, 4)
                    }
                    Spacer()
                }.padding(.top, 30)

                if viewModel.isEditing {
                    if !viewModel.showDatePicker {
                        Button(action: { viewModel.showDatePicker = true }) {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Seleccionar fecha")
                                Spacer()
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(textFieldBackground))
                        }
                    } else {
                        VStack(spacing: 8) {
                            DatePicker(
                                "Selecciona una fecha",
                                selection: Binding(
                                    get: { viewModel.editableProject.endDate ?? Date() },
                                    set: { viewModel.editableProject.endDate = $0 }
                                ),
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)

                            Button("Eliminar fecha") {
                                viewModel.editableProject.endDate = nil
                                viewModel.showDatePicker = false
                            }
                            .foregroundColor(.red)
                        }
                    }
                }

                // Descripción
                VStack(alignment: .leading) {
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    if viewModel.isEditing {
                        TextEditor(text: Binding(
                            get: { viewModel.editableProject.descriptionProject ?? "" },
                            set: { viewModel.editableProject.descriptionProject = $0 }
                        ))
                        .font(.body)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 100)
                        .background(RoundedRectangle(cornerRadius: 12).fill(textFieldBackground))
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                    } else {
                        Text((viewModel.editableProject.descriptionProject?.isEmpty ?? true)
                             ? "No hay descripción disponible."
                             : viewModel.editableProject.descriptionProject!)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(textFieldBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Botones
                VStack(spacing: 16) {
                    Button(action: { viewModel.markAsCompleted() }) {
                        if viewModel.editableProject.status == .on {
                            Text("Marcar como completado")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.45, blue: 0.75),
                                            Color(red: 0.0, green: 0.35, blue: 0.65)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        } else {
                            Text("Proyecto completado")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }

                    if viewModel.isEditing {
                        Button(action: { viewModel.saveProject() }) {
                            Text("Guardar Proyecto")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.taskButtonColor)
                                )
                        }
                    }
                }

                // Carruseles
                TaskList(editableProject: viewModel.editableProject)
                NotesCarrousel(editableProject: viewModel.editableProject)
                EventCarrousel(editableProject: viewModel.editableProject)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
