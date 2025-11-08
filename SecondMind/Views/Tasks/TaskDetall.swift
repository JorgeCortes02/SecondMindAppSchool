import SwiftUI
import SwiftData

struct TaskDetall: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var modelView: TaskDetailViewModel

    // 🎨 Mismos acentos visuales que en CreateTask
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke   = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.2)
    private let fieldBG      = Color(red: 248/255, green: 248/255, blue: 250/255)

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

            ScrollView {
                VStack(spacing: 0) {

                    // 🧾 Tarjeta principal (idéntica estructura que CreateTask)
                    VStack(spacing: 26) {

                        // Encabezado (equivalente a headerCard en CreateTask)
                        headerCard

                        Divider().padding(.horizontal, 20)

                        // ——— Título (misma lógica) ———
                        Group {
                            if modelView.isEditing {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Título")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    TextEditor(text: $modelView.editableTask.title)
                                        .font(.body)
                                        .scrollContentBackground(.hidden)
                                        .padding(12)
                                        .frame(minHeight: 100)
                                        .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                        .onChange(of: modelView.editableTask.title) { newValue in
                                            if newValue.contains("\n") {
                                                modelView.editableTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                            }
                                        }
                                }
                                .padding(.horizontal, 20)
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Título")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Text(modelView.editableTask.title)
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Divider().padding(.horizontal, 20)

                        // ——— Descripción (misma lógica) ———
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
                                .padding(12)
                                .frame(minHeight: 100)
                                .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                            } else {
                                Text((modelView.editableTask.descriptionTask?.isEmpty ?? true)
                                     ? "No hay descripción disponible."
                                     : modelView.editableTask.descriptionTask!)
                                .font(.body)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(fieldBG)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Proyecto y Evento (mismo layout vertical que CreateTask) ———
                        VStack(spacing: 16) {

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
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .onChange(of: modelView.editableTask.project) { newProject in
                                        // ✅ Respetamos tu flujo: el ViewModel decide cómo filtrar/forzar evento
                                        modelView.updateProjectSelection(newProject)
                                    }
                                } else {
                                    Text(modelView.editableTask.project?.title ?? "Sin proyecto asignado")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(fieldBG)
                                        .cornerRadius(12)
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
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .onChange(of: modelView.editableTask.event) { newEvent in
                                        // ✅ Respetamos tu flujo: si el evento tiene proyecto, el VM lo asigna
                                        modelView.updateEventSelection(newEvent)
                                    }
                                } else {
                                    Text(modelView.editableTask.event?.title ?? "Sin evento asignado")
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(fieldBG)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Fecha (misma lógica que tenías, estilo CreateTask) ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)

                            if let event = modelView.editableTask.event {
                                // Si está asociada a evento: muestra fecha del evento + nota
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.orange)
                                        Text(utilFunctions.formattedDateAndHour(event.endDate))
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))

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
                                            .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
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
                                            .foregroundColor(.orange)
                                        if let date = modelView.editableTask.endDate {
                                            Text(utilFunctions.formattedDateAndHour(date))
                                        } else {
                                            Text("Sin fecha establecida")
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Botones (los tuyos, mismo estilo de CreateTask para coherencia) ———
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
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(modelView.editableTask.status == .on ? Color.taskButtonColor : Color.gray.opacity(0.5))
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
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            LinearGradient(colors: [Color.taskButtonColor, purpleAccent],
                                                           startPoint: .leading,
                                                           endPoint: .trailing)
                                            .cornerRadius(12)
                                        )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
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

    // Encabezado (equivalente al de CreateTask)
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
        .padding(.top, 6)
    }
}

// 🎛️ Igual que en tu versión
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
