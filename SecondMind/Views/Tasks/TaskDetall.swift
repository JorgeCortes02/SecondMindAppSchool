import SwiftUI
import SwiftData

struct TaskDetall: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    @StateObject private var modelView: TaskDetailViewModel

    init(editableTask: TaskItem) {
        _modelView = StateObject(wrappedValue: TaskDetailViewModel(task: editableTask, context: editableTask.modelContext!))
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: { modelView.toggleEdit() }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: { modelView.deleteTask(dismiss: dismiss) }) {
                            Image(systemName: "trash")
                        }
                    }
                }

            VStack(spacing: 10) {
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                headerCard
                    .padding(.top, 20)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
                    .scaleEffect(1.02)
                    .animation(.easeOut(duration: 0.4), value: modelView.editableTask.id)

                Spacer()

                ScrollView {
                    VStack(spacing: 32) {
                        titleSection
                        descriptionSection
                        projectEventSection
                        dueDateSection
                        actionButtons
                    }
                    .background(Color.white)
                    .cornerRadius(40)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }

                Spacer()
            }
        }
    }

    // MARK: – Secciones de UI

    private var titleSection: some View {
        Group {
            if modelView.isEditing {
                VStack(alignment: .leading) {
                    Text("Título")
                        .font(.headline)
                        .padding(.bottom, 4)

                    TextEditor(text: $modelView.editableTask.title)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 100)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                        .onChange(of: modelView.editableTask.title) { newValue in
                            if newValue.contains("\n") {
                                modelView.editableTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            } else {
                Text(modelView.editableTask.title)
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading) {
            Text("Descripción")
                .font(.headline)
                .padding(.bottom, 4)

            if modelView.isEditing {
                TextEditor(text: Binding(
                    get: { modelView.editableTask.descriptionTask ?? "" },
                    set: { modelView.editableTask.descriptionTask = $0 }
                ))
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 100)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
            } else {
                Text((modelView.editableTask.descriptionTask?.isEmpty ?? true) ? "No hay descripción disponible." : modelView.editableTask.descriptionTask!)
                    .font(.body)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }

    private var projectEventSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("Proyecto")
                    .font(.headline)
                    .padding(.bottom, 4)

                if modelView.isEditing {
                    Picker("Selecciona un proyecto", selection: $modelView.editableTask.project) {
                        Text("Sin proyecto").tag(nil as Project?)
                        ForEach(modelView.projects, id: \.self) { project in
                            Text(project.title).tag(project as Project?)
                        }
                    }
                    .onChange(of: modelView.editableTask.project) { newProject in
                        modelView.updateProjectSelection(newProject)
                    }
                } else {
                    Text(modelView.editableTask.project?.title ?? "No hay proyecto.")
                        .font(.body)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }

            VStack(alignment: .leading) {
                Text("Evento")
                    .font(.headline)
                    .padding(.bottom, 4)

                if modelView.isEditing {
                    Picker("Selecciona un evento", selection: $modelView.editableTask.event) {
                        Text("Sin evento").tag(nil as Event?)
                        ForEach(modelView.events, id: \.self) { event in
                            Text(event.title).tag(event as Event?)
                        }
                    }
                    .onChange(of: modelView.editableTask.event) { newEvent in
                        modelView.updateEventSelection(newEvent)
                    }
                } else {
                    Text(modelView.editableTask.event?.title ?? "No hay evento.")
                        .font(.body)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fecha de vencimiento")
                .font(.headline)
                .padding(.bottom, 4)

            if modelView.isEditing && modelView.editableTask.event == nil {
                if !modelView.showDatePicker {
                    Button(action: { modelView.showDatePicker = true }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Seleccionar fecha")
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
                    }
                } else {
                    DatePicker("Selecciona una fecha",
                               selection: Binding(
                                get: { modelView.editableTask.endDate ?? Date() },
                                set: { modelView.editableTask.endDate = $0 }),
                               in: Date()...,
                               displayedComponents: [.date])
                        .datePickerStyle(.compact)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    if let date = modelView.editableTask.endDate {
                        Text(utilFunctions.formattedDateAndHour(date))
                    } else {
                        Text("Esta tarea no tiene fecha")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }

    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                modelView.markAsCompleted(dismiss: dismiss)
            } label: {
                Text(modelView.editableTask.status == .on ? "Marcar como completada" : "Tarea completada")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(modelView.editableTask.status == .on ? Color.taskButtonColor : Color.gray)
                    )
            }
            .buttonStyle(ScaleButtonStyle())

            if modelView.isEditing {
                Button {
                    modelView.saveChanges()
                } label: {
                    Text("Guardar Tarea")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.taskButtonColor))
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var headerCard: some View {
        VStack(spacing: 10) {
            Text("Detalles de tu tarea")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.taskButtonColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

// MARK: – Efecto de botón escalado
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
