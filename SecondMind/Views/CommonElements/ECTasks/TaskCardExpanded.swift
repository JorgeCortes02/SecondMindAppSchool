//
//  TaskCardExpanded.swift
//  SecondMind
//
//  Created by Jorge Cortés on 2/11/25.
//
import SwiftUI


struct TaskCardExpanded: View {
    
    var task: TaskItem
    var accentColor: Color
    @Binding var listTask : [TaskItem]
    
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    
    var body: some View {
        NavigationLink(destination: TaskDetall(editableTask: task)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // ✅ Icono principal y título
                    HStack(spacing: 8) {
                        Image(systemName: task.endDate == nil ? "checklist" : "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                        
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                    
                    // ✅ Botón de completar
                    if task.status == .on {
                        Button(action: {
                            task.completeDate = Date()
                            task.status = .off
                            do {
                                Task {
                                    await SyncManagerUpload.shared.uploadTask(task: task)
                                }
                                try context.save()
                                
                                withAnimation(.easeOut(duration: 0.25)) {
                                    listTask.removeAll { $0.id == task.id }
                                }
                            } catch {
                                print("❌ Error al marcar tarea como completa: \(error)")
                            }
                        }) {
                            Image(systemName: "circle")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 6)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                            .padding(.leading, 6)
                    }
                }
                
                // 📁 Proyecto
                if let project = task.project {
                    Label(project.title, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.purple) // 💜 Color para proyectos
                } else {
                    Label("Sin proyecto", systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                // 📅 Evento
                if let event = task.event {
                    Label(event.title, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(Color.eventButtonColor) // 🎨 Color para eventos
                } else {
                    Label("Sin evento", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                // ⏰ Hora (si tiene fecha)
                if let due = task.endDate {
                    HStack {
                        Image(systemName: "clock")
                        Text(utilFunctions.extractHour(due))
                    }
                    .font(.caption)
                    .foregroundColor(accentColor)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            
        }
        .buttonStyle(.plain)
    }
    
}

