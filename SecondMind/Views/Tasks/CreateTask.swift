import SwiftUI
import SwiftData

struct CreateTask: View {
    @State private var newTask: TaskItem

    init(project: Project? = nil) {
        self._newTask = State(initialValue: TaskItem(
            title: "",
            endDate: nil,
            project: project,
            event: nil,
            status: .on,
            descriptionTask: ""
        ))
    }

    let softRed = Color(red: 220/255, green: 75/255, blue: 75/255)
    let textFieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss

    @State private var events: [Event] = []
    @State private var projects: [Project] = []
    @State private var isIncompleteTask: Bool = false
    @State private var ShowDatePicker: Bool = false

    var body: some View {
        ZStack {
            // Fondo degradado suave
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
                            
                            TextField("Escribe el título", text: $newTask.title)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: newTask.title) { newValue in
                                    newTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                }
                        }
                        .padding(.horizontal, 20)
                        
                        if isIncompleteTask {
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
                                get: { newTask.descriptionTask ?? "" },
                                set: { newTask.descriptionTask = $0 }
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
                                Picker("Selecciona un proyecto", selection: $newTask.project) {
                                    Text("Sin proyecto").tag(nil as Project?)
                                    ForEach(projects, id: \.self) { project in
                                        Text(project.title).tag(project as Project?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: newTask.project) { newProject in
                                    if newTask.event == nil {
                                        newTask.endDate = newProject?.endDate
                                    }
                                    events = newProject.map { HomeApi.downdloadEventsFromProject(project: $0, context: context) } ?? []
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evento")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Picker("Selecciona un evento", selection: $newTask.event) {
                                    Text("Sin evento").tag(nil as Event?)
                                    ForEach(events, id: \.self) { event in
                                        Text(event.title).tag(event as Event?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: newTask.event) { newEvent in
                                    newTask.project = newEvent?.project
                                    newTask.endDate = newEvent?.endDate
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if newTask.event == nil {
                                if !ShowDatePicker {
                                    Button {
                                        ShowDatePicker = true
                                        newTask.endDate = Date()
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
                                                get: { newTask.endDate ?? Date() },
                                                set: { newTask.endDate = $0 }
                                            ),
                                            in: Date()...,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)
                                        
                                        Button("Eliminar fecha") {
                                            newTask.endDate = nil
                                            ShowDatePicker = false
                                        }
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    }
                                }
                            } else {
                                HStack {
                                    Image(systemName: "calendar")
                                    if let date = newTask.endDate {
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
                            Button(action: saveTask) {
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
            events = HomeApi.downdloadEventsFrom(context: context)
            projects = HomeApi.downdloadProjectsFrom(context: context)
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

    private func saveTask() {
        if newTask.title.isEmpty {
            isIncompleteTask = true
        } else {
            isIncompleteTask = false
            context.insert(newTask)
            if let project = newTask.project {
                project.tasks.append(newTask)
            }
            do {
                try context.save()
            } catch {
                print("❌ Error al guardar tarea: \(error)")
            }
            dismiss()
        }
    }
}
