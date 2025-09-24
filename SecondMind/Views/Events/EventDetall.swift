//
//  EventDetall.swift
//  SecondMind
//
//  Created by Jorge Cortés on 8/6/25.
//

import SwiftUI
import SwiftData

struct EventDetall: View {
    // Variables que vienen de fuera
    @Bindable var editableEvent: Event
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    
    @StateObject var viewModel: EventDetallModelView
    
    init(editableEvent: Event) {
        self._editableEvent = Bindable(editableEvent)
        _viewModel = StateObject(wrappedValue: EventDetallModelView())
    }
    
    // Variables de estilo
    let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)
    
    // Variables de la vista
    @State var isEditing = false
    @State private var ShowDatePicker: Bool = false
    @State private var isIncompleteTask: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "trash")
                        }
                    }
                }
            
            VStack(spacing: 10) {
                // Header externo
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                
                
                
                Spacer()
                
                // Contenido principal
                ScrollView {
                    VStack(spacing: 32) {
                        
                        if isEditing {
                            // 🔹 Campo título editable
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
                                        if newValue.contains("\n") {
                                            editableEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                        }
                                    }
                                
                                HStack {
                                    Spacer()
                                    if isIncompleteTask {
                                        Text("Es obligatorio añadir un titulo")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        } else {
                            // 🔹 Campo título en solo lectura
                            Text(editableEvent.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                                .padding()
                                .opacity(0.9)
                                .padding(.top, 20)
                        }
                        
                        // 🔹 Sección: Descripción + Proyecto
                        VStack(alignment: .leading, spacing: 36) {
                            // Descripción
                            VStack(alignment: .leading) {
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 4)
                                
                                if isEditing {
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
                                } else {
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
                            
                            // Proyecto
                            HStack(spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("Proyecto")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.bottom, 4)
                                    
                                    if isEditing {
                                        Picker("Selecciona un proyecto", selection: $editableEvent.project) {
                                            Text("Sin proyecto").tag(nil as Project?)
                                            ForEach(viewModel.projects, id: \.self) { project in
                                                Text(project.title).tag(project as Project?)
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
                                    } else {
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
                        
                        // 🔹 Sección: Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha de vencimiento")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.bottom, 4)
                            
                            if isEditing {
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
                                }
                                .padding(.bottom, 16)
                            } else {
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
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                                .padding(.bottom, 16)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // ✅ 🔹 NUEVA SECCIÓN: Notas del evento
                        NotesCarrousel(editableEvent: editableEvent)
                            .padding(.horizontal, 8)
                        
                        // 🔹 Botones principales
                        VStack(spacing: 16) {
                            NavigationLink(
                                destination: NoteDetailView(event: editableEvent)
                            ) {
                                Label("Nueva nota", systemImage: "plus")  .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.blue)
                                    
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            Button(action: {
                                viewModel.deleteEvent(event: editableEvent)
                                utilFunctions.dismissViewFunc()
                            }) {
                                Text("Eliminar Evento")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
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
                            .buttonStyle(ScaleButtonStyle())
                            
                            if isEditing {
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
                    .background(Color.white)
                    .cornerRadius(40)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                
                Spacer()
            }
            .onAppear {
                viewModel.setContext(context: context)
                viewModel.getProjects()
            }
            .onChange(of: utilFunctions.dismissView) { value in
                if value {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: – Header interno
    private var headerCard: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Detalles de tu evento")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.eventButtonColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
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
