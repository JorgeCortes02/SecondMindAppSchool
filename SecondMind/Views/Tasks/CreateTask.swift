import SwiftUI
import SwiftData

struct CreateTask: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var utilFunctions: generalFunctions
    @StateObject private var modelView: CreateTaskViewModel

    // 🎨 Colores acorde al estilo de TaskDetall
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.2)
    private let fieldBG = Color(red: 248/255, green: 248/255, blue: 250/255)

    init(project: Project? = nil) {
        _modelView = StateObject(wrappedValue: CreateTaskViewModel(project: project))
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                 

                    // 🧾 Tarjeta principal
                    VStack(spacing: 26) {
                        // Encabezado
                        headerCard

                        Divider().padding(.horizontal, 20)

                        // ——— Campo título (MISMA LÓGICA) ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("Escribe el título", text: $modelView.newTask.title)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: modelView.newTask.title) { newValue in
                                    modelView.newTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                }
                        }
                        .padding(.horizontal, 20)

                        if modelView.isIncompleteTask {
                            Text("⚠️ Es obligatorio añadir un título")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        Divider().padding(.horizontal, 20)

                        // ——— Campo descripción (MISMA LÓGICA) ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextEditor(text: Binding(
                                get: { modelView.newTask.descriptionTask ?? "" },
                                set: { modelView.newTask.descriptionTask = $0 }
                            ))
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Pickers Proyecto y Evento (MISMA LÓGICA) ———
                        VStack(spacing: 16) {
                            // Proyecto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Proyecto")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Picker("Selecciona un proyecto", selection: $modelView.newTask.project) {
                                    Text("Sin proyecto").tag(nil as Project?)
                                    ForEach(modelView.projects, id: \.self) { project in
                                        Text(project.title).tag(project as Project?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .disabled(modelView.lockProject)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: modelView.newTask.project) { newProject in
                                    modelView.updateProjectSelection(newProject)
                                }
                            }

                            // Evento
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evento")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Picker("Selecciona un evento", selection: $modelView.newTask.event) {
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
                                .onChange(of: modelView.newTask.event) { newEvent in
                                    modelView.updateEventSelection(newEvent)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Fecha (MISMA LÓGICA) ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)

                            if modelView.newTask.event == nil {
                                if !modelView.showDatePicker {
                                    Button {
                                        modelView.showDatePicker = true
                                        modelView.newTask.endDate = Date()
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
                                    VStack(alignment: .leading, spacing: 8) {
                                        DatePicker(
                                            "Selecciona una fecha",
                                            selection: Binding(
                                                get: { modelView.newTask.endDate ?? Date() },
                                                set: { modelView.newTask.endDate = $0 }
                                            ),
                                            in: Date()...,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)

                                        Button("Eliminar fecha") {
                                            modelView.newTask.endDate = nil
                                            modelView.showDatePicker = false
                                        }
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "calendar")
                                    if let date = modelView.newTask.endDate {
                                        Text(utilFunctions.formattedDateShort(date))
                                    } else {
                                        Text("Sin fecha")
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                            }
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Botones (MISMA LÓGICA) con estética TaskDetall ———
                        VStack(spacing: 14) {
                            Button {
                                modelView.saveTask(dismiss: dismiss)
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

                            Button(action: { dismiss() }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.red.opacity(0.85))
                                    )
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
        .onAppear {
            modelView.configure(context: context)
        }
    }

    // Encabezado estilizado (mantiene tu título)
    private var headerCard: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.taskButtonColor)
            Text("Crear tarea")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.taskButtonColor)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }
}
