import SwiftUI
import SwiftData
struct TaskDetall: View {
  
    @Bindable var editableTask: TaskItem // Una copia editable temporal
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    // Color de fondo para los campos de texto
    let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)
    
    @State private var events: [Event] = []
    @State private var projects: [Project] = []
    @State var isEditing = false
    @State private var ShowDatePicker: Bool = false
    @State private var isIncompleteTask: Bool = false
    var body: some View {
        ZStack {
            // Fondo general con un ligero color pastel
           BackgroundColorTemplate()
            .ignoresSafeArea()
            .toolbar {
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {isEditing = true} ){
                        Image(systemName: "pencil")
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "trash")
                    }
                }
            }
            VStack(spacing: 10) {
                // ——— Header externo (sin cambios estructurales, pero con estilo) ———
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                
                // ——— Header interno (“Detalles de tu tarea”), con sombra y animación ———
                headerCard
                    .padding(.top, 20)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
                    .scaleEffect(1.02) // leve zoom para destacar
                    .animation(.easeOut(duration: 0.4), value: editableTask.id)
                
                Spacer()
                
                // ——— Contenido principal dentro de un ScrollView ———
                ScrollView {
                    VStack(spacing: 32) {
                        if isEditing{
                            
                            VStack(alignment: .leading) {
                                
                                Text("Titulo")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 4)
                                
                                TextEditor(text: $editableTask.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .scrollContentBackground(.hidden)
                                    .padding(12)
                                    .frame(minHeight: 100)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(textFieldBackground)
                                    )
                                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                    .onChange(of: editableTask.title) { newValue in
                                                    // Eliminar todos los saltos de línea
                                                    if newValue.contains("\n") {
                                                        editableTask.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                                    }
                                                }
                                
                                HStack{
                                    Spacer()
                                    if isIncompleteTask{
                                        
                                        Text("Es obligatorio añadir un titulo").font(.caption).foregroundStyle(.red)
                                    }
                                    Spacer()
                                }
                                
                            }.padding(.horizontal, 20).padding(.top, 20)
                        }else{
                            Text(editableTask.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding()
                                .opacity(0.9).padding(.top, 20)
                        }
                        
                        
                        // Sección: Descripción y Proyectos/Evento
                        VStack(alignment: .leading, spacing: 36) {
                            // – Descripción –
                            VStack(alignment: .leading) {
                                
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 4)
                                if isEditing{
                                    
                                    TextEditor(text: Binding(
                                            get: { editableTask.descriptionTask ?? "" },
                                            set: { editableTask.descriptionTask = $0 }
                                        ))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .scrollContentBackground(.hidden)
                                        .padding(12)
                                        .frame(minHeight: 100)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(textFieldBackground)
                                        )
                                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                    
                                    
                                }else{
                                   
                                    Text((editableTask.descriptionTask?.isEmpty ?? true) ? "No hay descripción disponible." : editableTask.descriptionTask!)
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
                            
                            // – Proyecto y Evento en dos columnas –
                            HStack(spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("Proyecto")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.bottom, 4)
                                    
                                    if isEditing{
                                        
                                        Picker("Selecciona un proyecto", selection: $editableTask.project){
                                            Text("Sin proyecto").tag(nil as Project?)
                                            ForEach(projects, id: \.self){ project in
                                                Text(project.title).tag(project as Project?)
                                                
                                            }
                                        }.pickerStyle(.menu).font(.body)
                                            .foregroundColor(.primary)
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                            .onChange(of: editableTask.project){ newProyect in
                                                
                                                if(editableTask.event == nil){
                                                    
                                                    editableTask.endDate = newProyect?.endDate ?? nil
                                                    
                                                }
                                                
                                                if let safeProject = newProyect {
                                                    events = HomeApi.downdloadEventsFromProject(project: safeProject, context: context)
                                                } else {
                                                    events = [] // sin proyecto → vacía lista de eventos
                                                }

                                            }
                                        
                                    }else{
                                        
                                                   Text(editableTask.project?.title ?? "No hay proyecto.")
                                                       .font(.body)
                                                       .foregroundColor(.primary)
                                                       .padding(12)
                                                       .frame(maxWidth: .infinity, alignment: .leading)
                                                       .background(textFieldBackground)
                                                       .cornerRadius(12)
                                                       .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                               }
                                           
                                    }
                             
                                
                                VStack(alignment: .leading) {
                                    
                                    if isEditing{
                                        Text("Evento")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.bottom, 4)
                                        
                                        Picker("Selecciona un evento", selection: $editableTask.event) {
                                            Text("Sin evento").tag(nil as Event?)

                                            ForEach(events, id: \.self) { event in
                                                Text(event.title).tag(event as Event?)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                        .onChange(of: editableTask.event) { newEvent in
                                            editableTask.project = newEvent?.project       // ✅ asigna el proyecto del evento
                                            editableTask.endDate = newEvent?.endDate       // ✅ asigna la fecha del evento
                                        }
                                    }else{
                                        
                                        Text("Evento")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.bottom, 4)
                                        
                                        Text(editableTask.event?.title ?? "No hay evento.")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                    }
                                   
                                    
                                    
                                        
                                    
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Sección: Fecha de vencimiento con sombra y borde semitransparente
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            
                            
                            if isEditing && editableTask.event == nil {
                              
                                if !ShowDatePicker {
                                    Button(action: { ShowDatePicker = true }) {
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
                                                get: { editableTask.endDate ?? Date() },
                                                set: { editableTask.endDate = $0 }
                                            ),
                                            in: Date()...,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)

                                        Button("Eliminar fecha") {
                                            editableTask.endDate = nil
                                            ShowDatePicker = false
                                        }
                                        .foregroundColor(.red)
                                    }
                                }
                                
                                
                               
                            }else{
                                
                                HStack(spacing: 8) {
                                    
                                 
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                    if let date = editableTask.endDate {
                                        Text(date.formatted(date: .long, time: .shortened))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("Esta tarea no tiene fecha")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(textFieldBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                            }
                            
                            
                            
                        }
                        .padding(.horizontal, 24)
                        
                        // Botones principales con degradados y animación al presionar
                        VStack(spacing: 16) {
                            Button(action: {
                                editableTask.completeDate = Date()
                                editableTask.status = .off
                                do {
                                    try context.save()
                                    dismiss()
                                } catch {
                                    print("❌ Error al guardar: \(error)")
                                }
                            }) {
                                    if editableTask.status == .on
                                {
                                        Text("Marcar como completada")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                        // Fondo degradado azul
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
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                        
                                    }else{
                                        Text("Tarea completada")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                        // Fondo degradado azul
                                            .background(
                                               
                                                Color.gray.opacity(0.5)
                                            )
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                                }
                                        
                                     
                            }
                            .buttonStyle(ScaleButtonStyle()) // ligera animación al pulsar
                            if isEditing{
                                Button(action: {
                                    
                                  
                                        do {
                                               // Buscar la tarea real en el contexto
                                               let descriptor = FetchDescriptor<TaskItem>()
                                               let tasks = try context.fetch(descriptor)

                                               if let realTask = tasks.first(where: { $0.id == editableTask.id }) {
                                                   // Copiar los datos modificados desde editableTask
                                                   realTask.title = editableTask.title
                                                   realTask.descriptionTask = editableTask.descriptionTask
                                                   realTask.endDate = editableTask.endDate
                                                   // cualquier otro campo que hayas editado

                                                   // Guardar los cambios en la base de datos
                                                   try context.save()



                                               }

                                           } catch {
                                               print("❌ Error al guardar: \(error)")
                                           }
                                        isEditing = false
                                        
                                    
                                    
                                    }) {
                                        
                                        
                                            Text("Guardar Tarea")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.taskButtonColor)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.taskButtonColor, lineWidth: 1.5)
                                                )
                                       
                                        }     .buttonStyle(ScaleButtonStyle())
                                   
                                    }
                           

                                
                            
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    // Tarjeta blanca con esquinas muy redondeadas
                    .background(Color.white)
                    .cornerRadius(40)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                
                Spacer()
            }
        }.onAppear{
            events = HomeApi.downdloadEventsFrom(context: context)
            projects = HomeApi.downdloadProjectsFrom(context: context)
        }
    }

    // ——— headerCard tal como estaba, sin cambios estructurales ———
    private var headerCard: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Detalles de tu tarea")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.taskButtonColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            // Fondo semitransparente con degradado suave
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 0.8),
                        Color(red: 0.90, green: 0.90, blue: 0.93, opacity: 0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(20)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: – Efecto de “escalado” al pulsar botones
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
