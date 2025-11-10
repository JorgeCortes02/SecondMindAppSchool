import SwiftUI

struct NotesCarrousel: View {
    var editableProject: Project?
    var editableEvent: Event?

    @EnvironmentObject var utilFunctions: generalFunctions
    @StateObject private var modelView = NotesCarrouselModelView()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header con contador y "ver más"
            HStack {
                Text(editableEvent != nil ? "Notas del evento" : "Notas del proyecto")
                    .font(.headline)
                    .foregroundColor(Color.noteBlue)

                Text("\(modelView.notes.count)")
                    .bold()

                Spacer()

                // 🔹 NavigationLink dinámico según si hay project o event
                if let project = editableProject {
                    NavigationLink(destination: NotesView(project: editableProject)) {
                        HStack(spacing: 4) {
                            Text("Ver más")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.noteBlue)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.noteBlue)
                        }
                    }
                } else if let event = editableEvent {
                    NavigationLink(destination: NotesView(event: editableEvent)) {
                        HStack(spacing: 4) {
                            Text("Ver más")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color.noteBlue)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.noteBlue)
                        }
                    }
                }
            }

            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)

            // Contenido
            if modelView.notes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "note.text.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color.noteBlue.opacity(0.7))

                    Text(editableEvent != nil ? "No tienes notas en este evento." : "No tienes notas en este proyecto.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(20)
            } else {
                GeometryReader { geometry in
                    let cardWidth = geometry.size.width * 0.85
                    let sideInset = (geometry.size.width - cardWidth) / 2

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(modelView.notes.prefix(5), id: \.id) { note in
                                NavigationLink(destination: NoteDetailView(note: note)) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        
                                        // 🔹 Título
                                        Text(note.title.isEmpty ? "Sin título" : note.title)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        
                                        HStack{
                                            // 🔹 Proyecto / Evento
                                            if let project = note.project {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "folder.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.orange)
                                                    Text(project.title)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(.orange)
                                                        .lineLimit(1)
                                                }
                                            }
                                            
                                            if let event = note.event {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "calendar")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.purple)
                                                    Text(event.title)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(.purple)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                        
                                    
                                        
                                       
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock.badge")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.gray)
                                                Text(utilFunctions.formattedDateAndHour(note.createdAt))
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                          
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: "pencil")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color.noteBlue.opacity(0.7))
                                                Text(utilFunctions.formattedDateAndHour(note.updatedAt))
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.noteBlue.opacity(0.7))
                                            
                                        }
                                    }
                                    .padding(16)
                                    .frame(width: cardWidth, height: 120, alignment: .topLeading)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, sideInset)
                    }
                    .frame(height: 120)
                }
                .frame(height: 140)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBG)
        .cornerRadius(40)
        .onAppear {
            if let project = editableProject {
                modelView.loadNotes(for: project)
            } else if let event = editableEvent {
                modelView.loadNotes(for: event)
            }
        }
    }
}
