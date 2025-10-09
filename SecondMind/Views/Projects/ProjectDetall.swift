//
//  ProjectDetall.swift
//  SecondMind
//
//  Created by Jorge Cortés on 25/7/25.
//

import SwiftUI
import SwiftData
struct ProjectDetall : View {
    
    @Bindable var editableProject : Project
    
    let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var utilFunctions: generalFunctions
    @State private var ShowDatePicker: Bool = false
    @State var isEditing = false
    @State private var showAddTaskView: Bool = false
    @State private var showAddEventView: Bool = false
    var body: some View{
   
      
        ZStack {
            // Fondo general con un ligero color pastel
           BackgroundColorTemplate()
            .ignoresSafeArea()
            
            VStack(spacing: 10) {
                // ——— Header externo (sin cambios estructurales, pero con estilo) ———
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                
                // ——— Header interno (“Detalles de tu tarea”), con sombra y animación ———
             
                
                Spacer()
                
                ZStack(alignment: .topLeading) {
                                            VStack(alignment: .leading) {
                                                ScrollView{

                            
                            VStack(){
                                
                                HStack{
                                    if isEditing {
                                        TextField("Título", text: $editableProject.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(textFieldBackground)
                                            )
                                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                          
                                            
                                        
                                    }else{
                                        Image(systemName: "folder").font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.taskButtonColor)
                                            .padding(.bottom, 4)
                                        
                                        Text(editableProject.title)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.taskButtonColor)
                                            .padding(.bottom, 4).lineLimit(1).toolbar {
                                                
                                                ToolbarItemGroup(placement: .topBarTrailing) {
                                                        Button(action: {isEditing = true} ){
                                                            Image(systemName: "pencil")
                                                        }

                                                    Button(action: {}) {
                                                            Image(systemName: "trash")
                                                        }
                                                    }
                                                
                                              }
                                    }
                                }
                                
                                HStack() {
                                    
                                    Text("Estado:")   .font(.headline)
                                        .foregroundColor(Color.taskButtonColor)
                                    
                                    
                                    
                                    
                                    if editableProject.status == .on {
                                        
                                        Text("Activo").foregroundStyle(Color(red: 0/255, green: 100/255, blue: 0/255)).bold()
                                        
                                    }else{
                                        Text("Finalizado").foregroundStyle(Color(red: 153/255, green: 0/255, blue: 51/255))
                                    }
                                    
                                    
                                    
                                }
                                
                                VStack(){
                                    HStack(spacing: 24) {
                                        Label {
                                            Text("Tareas: \(editableProject.tasks.filter { $0.status == .on }.count)")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundColor(.primaryText)
                                        } icon: {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(.taskButtonColor)
                                        }
                                        
                                        Label {
                                            Text("Eventos: \(editableProject.events.filter { $0.status == .on }.count)")
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
                                    // Botones de nueva tarea y nuevo evento usando RoundedButtonStyle
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            showAddTaskView = true
                                        }) {
                                            Label("Nueva Tarea", systemImage: "checkmark.circle")
                                        }.sheet(isPresented: $showAddTaskView, onDismiss: {
                                            
                                            showAddTaskView = false
                                        }){
                                            CreateTask(project: editableProject)
                                        }
                                        .buttonStyle(RoundedButtonStyle(backgroundColor: .taskButtonColor))
                                        
                                        Button(action: {
                                            showAddEventView = true
                                        }) {
                                            Label("Nuevo Evento", systemImage: "calendar.badge.plus")
                                        }.sheet(isPresented: $showAddEventView, onDismiss: {
                                           
                                            showAddEventView = false
                                        }){
                                            CreateEvent(project: editableProject)
                                        }
                                        .buttonStyle(RoundedButtonStyle(backgroundColor: .eventButtonColor))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                                                       
                                    NavigationLink(
                                        destination: NoteDetailView(project: editableProject)
                                    ) {
                                        Label("Nueva nota", systemImage: "plus")
                                    }.buttonStyle(RoundedButtonStyle(backgroundColor: .blue))
                                              }.padding(.top, 10)


                            }.padding().padding(.bottom, 0).frame(maxWidth: .infinity).background(Color(red: 228/255, green: 214/255, blue: 244/255)).cornerRadius(30, corners: [.topLeft, .topRight])
                            
                            
                            HStack(){
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8){
                                        Spacer()
                                        Text("Fecha fin: ")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.bottom, 4)
                                        if let date = editableProject.endDate {
                                            Text(utilFunctions.formattedDateShort(date))
                                                .font(.headline).padding(.bottom, 4)
                                                .foregroundColor(Color.eventButtonColor)
                                        } else {
                                            Text("Sin fecha")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 10)
                                    
                                    
                                    if isEditing {
                                        
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
                                                        get: { editableProject.endDate ?? Date() },
                                                        set: { editableProject.endDate = $0 }
                                                    ),
                                                    in: Date()...,
                                                    displayedComponents: [.date]
                                                )
                                                .datePickerStyle(.compact)
                                                
                                                Button("Eliminar fecha") {
                                                    editableProject.endDate = nil
                                                    ShowDatePicker = false
                                                }
                                                .foregroundColor(.red)
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                            .padding(.horizontal, 24)
                            
                            
                            VStack(alignment: .leading) {
                                
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 4)
                                if isEditing{
                                    
                                    TextEditor(text: Binding(
                                        get: { editableProject.descriptionProject ?? "" },
                                        set: { editableProject.descriptionProject = $0 }
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
                                    
                                    Text((editableProject.descriptionProject?.isEmpty ?? true) ? "No hay descripción disponible." : editableProject.descriptionProject!)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(textFieldBackground)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                            }.padding()
                                .padding(.horizontal, 10)
                            
                                                    VStack(spacing: 16) {
                                                        Button(action: {
                                                            editableProject.endDate = Date()
                                                            editableProject.status = .off
                                                            do {
                                                                try context.save()
                                                                Task{
                                                                    
                                                                    await SyncManagerUpload.shared.uploadProject(project: editableProject)
                                                                    
                                                                }
                                                                dismiss()
                                                            } catch {
                                                                print("❌ Error al guardar: \(error)")
                                                            }
                                                        }) {
                                                                if editableProject.status == .on
                                                            {
                                                                    Text("Marcar como completado")
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
                                                                    Text("Evento completado")
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
                                                                           let descriptor = FetchDescriptor<Project>()
                                                                           let projects = try context.fetch(descriptor)

                                                                           if let realTask = projects.first(where: { $0.id == editableProject.id }) {
                                                                               // Copiar los datos modificados desde editableTask
                                                                               realTask.title = editableProject.title
                                                                               realTask.descriptionProject = editableProject.descriptionProject
                                                                               realTask.endDate = editableProject.endDate
                                                                               // cualquier otro campo que hayas editado

                                                                               // Guardar los cambios en la base de datos
                                                                               try context.save()

                                                                               Task{
                                                                                   
                                                                                   await SyncManagerUpload.shared.uploadProject(project: realTask)
                                                                                   
                                                                               }

                                                                           }

                                                                       } catch {
                                                                           print("❌ Error al guardar: \(error)")
                                                                       }
                                                                    isEditing = false
                                                                    
                                                                
                                                                
                                                                }) {
                                                                    
                                                                    
                                                                        Text("Guardar Proyecto")
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
                                                 
                                                    
                                                    
                                                    
                            
                            TaskList(editableProject: editableProject)
                            NotesCarrousel(editableProject: editableProject)
                            EventCarrousel(editableProject: editableProject)
                            
                        }.padding().frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(40)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.purple, lineWidth: 0.5)
                            ).padding(.horizontal, 10)
                       
                    }
                }
               
               
                Spacer()
            }
                

            }
        
    
        
        
        
    }

private var headerCard: some View {
    VStack(spacing: 10) {
        ZStack {
            Text("Tu proyecto")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.purple)
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
