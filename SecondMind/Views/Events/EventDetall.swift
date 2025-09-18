//
//  EventDetall.swift
//  SecondMind
//
//  Created by Jorge Cortés on 8/6/25.
//

import SwiftUI
import SwiftData
struct EventDetall: View {
  
    
   
    //Variables que vienen de fuera (viewModel, parametros...)
    @Bindable var editableEvent: Event
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions : generalFunctions = generalFunctions()
    
    @StateObject var viewModel : EventDetallModelView
    
    init(editableEvent: Event) {
        self._editableEvent = Bindable(editableEvent)
        _viewModel = StateObject(wrappedValue: EventDetallModelView())
    }
    
    // Variables de color y estilo.
    
    let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)
    
   //Variables de la vista
    @State var isEditing = false
    @State private var ShowDatePicker: Bool = false
    @State private var isIncompleteTask: Bool = false
    
    
    var body: some View {
        ZStack {
            // Fondo general con un ligero color pastel
           BackgroundColorTemplate()
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
                    .animation(.easeOut(duration: 0.4), value: editableEvent.id)
                
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
                                
                                TextEditor(text: $editableEvent.title)
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
                                    .onChange(of: editableEvent.title) { newValue in
                                                    // Eliminar todos los saltos de línea
                                                    if newValue.contains("\n") {
                                                        editableEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
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
                            Text(editableEvent.title)
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
                                            get: { editableEvent.descriptionEvent ?? "" },
                                            set: { editableEvent.descriptionEvent = $0 }
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
                                   
                                    Text((editableEvent.descriptionEvent?.isEmpty ?? true) ? "No hay descripción disponible." : editableEvent.descriptionEvent!)
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
                                        
                                        Picker("Selecciona un proyecto", selection: $editableEvent.project){
                                            Text("Sin proyecto").tag(nil as Project?)
                                            ForEach(viewModel.projects, id: \.self){ project in
                                                Text(project.title).tag(project as Project?)
                                                
                                            }
                                        }.pickerStyle(.menu).font(.body)
                                            .foregroundColor(.primary)
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(textFieldBackground)
                                            .cornerRadius(12)
                                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                          
                                    }else{
                                        
                                                   Text(editableEvent.project?.title ?? "No hay proyecto.")
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
                        .padding(.horizontal, 16)
                        
                        // Sección: Fecha de vencimiento con sombra y borde semitransparente
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            
                            
                            if isEditing  {
                              
                              
                                    VStack(spacing: 8) {
                                        DatePicker(
                                            "Selecciona una fecha",
                                            selection: $editableEvent.endDate,
                                            in: Date()...,
                                            displayedComponents: [.date]
                                        )
                                        .datePickerStyle(.compact)
                                        DatePicker(
                                            "Selecciona una hora",
                                            selection: $editableEvent.endDate,
                                            displayedComponents: [.hourAndMinute]
                                        )
                                        .datePickerStyle(.compact)
                                       
                                    }.padding(.bottom, 16)
                                
                                
                                
                               
                            }else{
                                
                                HStack(spacing: 8) {
                                    
                                 
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                  
                                    Text(editableEvent.endDate.formatted(date: .long, time: .shortened))
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(textFieldBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4).padding(.bottom, 16)
                            }

                            }.padding(.horizontal, 16)
                            
                            
                            
                        }
                        
                        
                        // Botones principales con degradados y animación al presionar
                        VStack(spacing: 16) {
                            Button(action: {
                                
                                viewModel.deleteEvent(event: editableEvent)
                                utilFunctions.dismissViewFunc()
                            }) {
                                Text("Eliminar Evento")
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
                            }
                            .buttonStyle(ScaleButtonStyle()) // ligera animación al pulsar
                            if isEditing
                            {
                                Button(action: {
                                    
                                  
                                    viewModel.saveEvent(event: editableEvent)
                                    
                                    isEditing = false
                                 
                                    }) {
                                        
                                       
                                            Text("Guardar Evento")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.eventButtonColor)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.eventButtonColor, lineWidth: 1.5)
                                                )
                                      
                                   
                                }
                                .buttonStyle(ScaleButtonStyle())
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
            }.onAppear{
                viewModel.setContext(context: context)
                viewModel.getProjects()
            }.onChange(of: utilFunctions.dismissView){value in
                if value {
                    dismiss()
                }
            }
        }
    

    // ——— headerCard tal como estaba, sin cambios estructurales ———
    private var headerCard: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Detalles de tu evento")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.eventButtonColor)
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

