import SwiftUI
import SwiftData

struct CreateTask: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @StateObject private var modelView: CreateTaskViewModel

    init(project: Project? = nil) {
        _modelView = StateObject(wrappedValue: CreateTaskViewModel(project: project))
    }

    let softRed = Color(red: 220/255, green: 75/255, blue: 75/255)
    let textFieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                headerCard
                    .padding(.top, 40)

                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Campo título
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            TextField("Escribe el título", text: $modelView.newTask.title)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
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
                        }

                        // Campo descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: Binding(
                                get: { modelView.newTask.descriptionTask ?? "" },
                                set: { modelView.newTask.descriptionTask = $0 }
                            ))
                            .frame(minHeight: 120)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        // Pickers Proyecto y Evento
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Proyecto")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Picker("Selecciona un proyecto", selection: $modelView.newTask.project) {
                                    Text("Sin proyecto").tag(nil as Project?)
                                    ForEach(modelView.projects, id: \.self) { project in
                                        Text(project.title).tag(project as Project?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: modelView.newTask.project) { newProject in
                                    modelView.updateProjectSelection(newProject)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evento")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Picker("Selecciona un evento", selection: $modelView.newTask.event) {
                                    Text("Sin evento").tag(nil as Event?)
                                    ForEach(modelView.events, id: \.self) { event in
                                        Text(event.title).tag(event as Event?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: modelView.newTask.event) { newEvent in
                                    modelView.updateEventSelection(newEvent)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
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
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
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
                                        Text(date.formatted(date: .long, time: .shortened))
                                    } else {
                                        Text("Sin fecha")
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            }
                        }
                        .padding(.horizontal, 20)

                        // Botones
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
                                        LinearGradient(colors: [Color.taskButtonColor, .purple],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                        .cornerRadius(14)
                                    )
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 14).fill(softRed))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            modelView.configure(context: context)
        }
    }

    private var headerCard: some View {
        Text("Crear tarea")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.taskButtonColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.white, Color.taskButtonColor.opacity(0.08)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
            )
            .padding(.horizontal, 20)
    }
}
