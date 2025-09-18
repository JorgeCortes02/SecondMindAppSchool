import SwiftUI
import SwiftData

struct CreateEvent: View {
    // Colores
    let softRed = Color(red: 220/255, green: 75/255, blue: 75/255)
    let textFieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)
    
    // Modelo
    @State private var newEvent: Event
    @State private var isIncompleteEvent: Bool = false
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    @StateObject var viewModel: CreateEventModelView
    
    init(project: Project? = nil) {
        self._newEvent = State(initialValue: Event(
            name: "",
            endDate: Date(),
            status: .on,
            project: project,
            descriptionEvent: ""
        ))
        _viewModel = StateObject(wrappedValue: CreateEventModelView())
    }
    
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
                            
                            TextField("Escribe el título", text: $newEvent.title)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: newEvent.title) { newValue in
                                    newEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                }
                        }
                        .padding(.horizontal, 20)
                        
                        if isIncompleteEvent {
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
                                get: { newEvent.descriptionEvent ?? "" },
                                set: { newEvent.descriptionEvent = $0 }
                            ))
                            .frame(minHeight: 120)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Picker de proyecto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proyecto")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Picker("Selecciona un proyecto", selection: $newEvent.project) {
                                Text("Sin proyecto").tag(nil as Project?)
                                ForEach(viewModel.projects, id: \.self) { project in
                                    Text(project.title).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Fecha y hora
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fecha y hora del evento")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                DatePicker(
                                    "Selecciona una fecha",
                                    selection: Binding(
                                        get: { newEvent.endDate ?? Date() },
                                        set: { newEvent.endDate = $0 }
                                    ),
                                    in: Date()...,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                
                                DatePicker(
                                    "Selecciona una hora",
                                    selection: Binding(
                                        get: { newEvent.endDate ?? Date() },
                                        set: { newEvent.endDate = $0 }
                                    ),
                                    displayedComponents: [.hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Botones
                        VStack(spacing: 14) {
                            Button(action: saveEvent) {
                                Text("Guardar Evento")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.eventButtonColor, .purple],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                        .cornerRadius(14)
                                    )
                            }
                            
                            Button(action: { utilFunctions.dismissViewFunc() }) {
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
            viewModel.setContext(context: context)
            viewModel.loadProjects()
        }
        .onChange(of: utilFunctions.dismissView) { value in
            if value { dismiss() }
        }
    }
    
    private var headerCard: some View {
        Text("Crear evento")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.eventButtonColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.white, Color.eventButtonColor.opacity(0.08)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
            )
            .padding(.horizontal, 20)
    }
    
    private func saveEvent() {
        if newEvent.title.isEmpty {
            isIncompleteEvent = true
        } else {
            context.insert(newEvent)
            if let project = newEvent.project {
                project.events.append(newEvent)
            }
            do {
                try context.save()
            } catch {
                print("❌ Error al guardar evento: \(error)")
            }
            dismiss()
        }
    }
}
