//
//  ProjectDetall.swift
//  SecondMind
//
//  Created by Jorge Cortés on 25/7/25.
//

import SwiftUI

struct CreateProject: View {
    let softRed = Color(red: 220/255, green: 75/255, blue: 75/255)
    let textFieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)
    
    @State private var newProject = Project(title: "", endDate: nil, description: "")
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    @State private var ShowDatePicker: Bool = false
    @State private var isIncompleteTitle: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo suave con gradiente vertical
           BackgroundColorTemplate()
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                headerCard
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Campo Título
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextField("Escribe el título", text: $newProject.title)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        if isIncompleteTitle {
                            Text("⚠️ Es obligatorio añadir un título")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        // Fecha
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha fin")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            DatePicker(
                                "Selecciona una fecha",
                                selection: Binding(
                                    get: { newProject.endDate ?? Date() },
                                    set: { newProject.endDate = $0 }
                                ),
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            
                            if newProject.endDate != nil {
                                Button("Eliminar fecha") {
                                    newProject.endDate = nil
                                    ShowDatePicker = false
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            TextEditor(
                                text: Binding(
                                    get: { newProject.descriptionProject ?? "" },
                                    set: { newProject.descriptionProject = $0 }
                                )
                            )
                            .frame(minHeight: 120)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Botones
                        VStack(spacing: 14) {
                            Button(action: saveProject) {
                                Text("Guardar Proyecto")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.purple, Color.pink],
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
    }
    
    private var headerCard: some View {
        Text("Crear proyecto")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.purple)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.white, Color.purple.opacity(0.05)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
            )
            .padding(.horizontal, 20)
    }
    
    private func saveProject() {
        if newProject.title.isEmpty {
            isIncompleteTitle = true
        } else {
            context.insert(newProject)
            do {
                try context.save()
            } catch {
                print("❌ Error al guardar proyecto: \(error)")
            }
            dismiss()
        }
    }
}
