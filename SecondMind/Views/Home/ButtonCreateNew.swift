//
//  ButtonCreateNew.swift
//  SecondMind
//
//  Created by Jorge Cortés on 7/11/25.
//

import SwiftUI

struct ButtonCreateNew: View {
    
    var funcAddTask: () -> Void
    var funcAddEvent: () -> Void
    var funcAddProject: () -> Void
    var funcAddNote: () -> Void
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var plusColors: [Color] = [.taskButtonColor, .eventButtonColor, .noteBlue, .projectPurpel]
    
    var body: some View {
        HStack(spacing: 14) {
            Spacer()
            
            PlusMenuButton(
                          
                            addTask: funcAddTask,
                            addEvent: funcAddEvent,
                            addProject: funcAddProject,
                       
                        )
                    }
                    .padding(.trailing, 30)
                    .padding(.bottom, sizeClass == .regular ? 90 : 120)
                  }
    }
    
  

    /// 🎨 Ícono `+` con degradado circular
    struct GradientPlusIcon: View {
        var size: CGFloat = 30
        
        var body: some View {
            Image(systemName: "plus")
                .font(.system(size: size, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.taskButtonColor,
                            Color.eventButtonColor,
                            Color.noteBlue,
                            Color.projectPurpel
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }


    /// Botón especial para abrir acciones desde el +
struct PlusMenuButton: View {
    
    var addTask: () -> Void
    var addEvent: () -> Void
    var addProject: () -> Void
   

    var body: some View {
        Menu {
            Button(action: addTask) {
                Label("Añadir tarea", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.taskButtonColor)
            }
            Divider()
            Button(action: addEvent) {
                Label("Añadir evento", systemImage: "calendar.badge.plus")
                    .foregroundStyle(Color.eventButtonColor)
            }
            Divider()
            Button(action: addProject) {
                Label("Añadir proyecto", systemImage: "folder.badge.plus")
                    .foregroundStyle(Color.projectPurpel)
            }
            Divider()
            NavigationLink(destination: NoteDetailView()) {
                                Label("Nueva Nota", systemImage: "note.text")
                            }
        } label: {
            if #available(iOS 26.0, *) {
                GradientPlusIcon()
                    .frame(width: 58, height: 58)
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
            } else {
                GradientPlusIcon()
                    .frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                    )
            }
        }
    }
}
