import SwiftUI
import SwiftData

struct TaskDetall: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var modelView: TaskDetailViewModel

    // 🎨 Estilo coherente con EventDetall
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke   = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.2)
    private let fieldBG      = Color.fieldBG

    init(editableTask: TaskItem) {
        _modelView = StateObject(wrappedValue: TaskDetailViewModel(task: editableTask, context: editableTask.modelContext!))
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: { modelView.isEditing ? modelView.saveChanges() : modelView.toggleEdit()
                        }) {
                            modelView.isEditing ? Image(systemName: "square.and.arrow.down")
  : Image(systemName: "pencil")
                        }
                        Button(action: {
                            modelView.deleteTask(dismiss: dismiss) }) {
                            Image(systemName: "trash")
                        }
                    }
                }

            ScrollView {
                VStack(spacing: 32) {

                    // 🧾 Tarjeta principal
                    VStack(spacing: 20) {

                        // Encabezado
                        headerCard

                        // ——— Título ———
                        VStack(alignment: .center, spacing: 12) {
                            if modelView.isEditing {
                                Text("Título")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                TextField("Escribe el título", text: $modelView.editableTask.title)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .onChange(of: modelView.editableTask.title) { newValue in
                                        if newValue.contains("\n") {
                                            modelView.editableTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                        }
                                    }
                            } else {
                                Text(modelView.editableTask.title)
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Descripción y Proyecto/Evento ———
                        VStack(alignment: .leading, spacing: 24) {
                            // Descripción
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                if modelView.isEditing {
                                    TextEditor(text: Binding(
                                        get: { modelView.editableTask.descriptionTask ?? "" },
                                        set: { modelView.editableTask.descriptionTask = $0 }
                                    ))
                                    .font(.body)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 100)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                } else {
                                    Text((modelView.editableTask.descriptionTask?.isEmpty ?? true)
                                         ? "No hay descripción disponible."
                                         : modelView.editableTask.descriptionTask!)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }

                            // Proyecto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Proyecto")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                if modelView.isEditing {
                                    Picker("Selecciona un proyecto", selection: $modelView.editableTask.project) {
                                        Text("Sin proyecto").tag(nil as Project?)
                                        ForEach(modelView.projects, id: \.self) { project in
                                            Text(project.title).tag(project as Project?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .disabled(modelView.lockProject)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .onChange(of: modelView.editableTask.project) { newProject in
                                        modelView.updateProjectSelection(newProject)
                                    }
                                } else {
                                    Text(modelView.editableTask.project?.title ?? "Sin proyecto asignado")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(fieldBG)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }

                            // Evento
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evento")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                if modelView.isEditing {
                                    Picker("Selecciona un evento", selection: $modelView.editableTask.event) {
                                        Text("Sin evento").tag(nil as Event?)
                                        ForEach(modelView.events, id: \.self) { event in
                                            Text(event.title).tag(event as Event?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .onChange(of: modelView.editableTask.event) { newEvent in
                                        modelView.updateEventSelection(newEvent)
                                    }
                                } else {
                                    Text(modelView.editableTask.event?.title ?? "Sin evento asignado")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(fieldBG)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Fecha ———
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)

                            if let event = modelView.editableTask.event {
                                // Si está asociada a evento
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text(utilFunctions.formattedDateAndHour(event.endDate))
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                                    Text("Esta tarea está vinculada a un evento")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                            } else {
                                if modelView.isEditing {
                                    if !modelView.showDatePicker {
                                        Button {
                                            modelView.showDatePicker = true
                                            if modelView.editableTask.endDate == nil {
                                                modelView.editableTask.endDate = Date()
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "calendar")
                                                Text("Seleccionar fecha")
                                                Spacer()
                                            }
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(fieldBG)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                    )
                                            )
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 10) {
                                            DatePicker(
                                                "Selecciona una fecha",
                                                selection: Binding(
                                                    get: { modelView.editableTask.endDate ?? Date() },
                                                    set: { modelView.editableTask.endDate = $0 }
                                                ),
                                                in: Date()...,
                                                displayedComponents: [.date]
                                            )
                                            .datePickerStyle(.compact)

                                            Button("Eliminar fecha") {
                                                modelView.editableTask.endDate = nil
                                                modelView.showDatePicker = false
                                            }
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        }
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "calendar")
                                        if let date = modelView.editableTask.endDate {
                                            Text(utilFunctions.formattedDateAndHour(date))
                                        } else {
                                            Text("Sin fecha establecida")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(fieldBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Botones ———
                        VStack(spacing: 14) {
                            Button {
                                modelView.markAsCompleted(dismiss: dismiss)
                            } label: {
                                Text(modelView.editableTask.status == .on ? "Marcar como completada" : "Tarea completada")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        modelView.editableTask.status == .on ? Color.taskButtonColor : Color.gray.opacity(0.5)
                                    )
                                    .cornerRadius(12)
                            }

                            if modelView.isEditing {
                                Button {
                                    modelView.saveChanges()
                                } label: {
                                    Text("Guardar Tarea")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.taskButtonColor)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: { modelView.deleteTask(dismiss: dismiss) }) {
                                Text("Eliminar Tarea")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 0.0, green: 0.45, blue: 0.75),
                                                     Color(red: 0.0, green: 0.35, blue: 0.65)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 22)
                    .frame(maxWidth: 800)
                    .background(
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(cardStroke, lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                }
            }
        }
    }

    // Encabezado
    private var headerCard: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.taskButtonColor)
            Text("Detalles de tu tarea")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.taskButtonColor)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
