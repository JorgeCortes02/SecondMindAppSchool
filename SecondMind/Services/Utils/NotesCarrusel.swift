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
                    .foregroundColor(.blue)

                Text("\(modelView.notes.count)")
                    .bold()

                Spacer()

                HStack(spacing: 4) {
                    Text("Ver más")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
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
                        .foregroundColor(Color.blue.opacity(0.7))

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
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(note.title.isEmpty ? "Sin título" : note.title)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)

                                        if let content = note.content, !content.isEmpty {
                                            Text(content)
                                                .font(.system(size: 14))
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }

                                        Label {
                                            Text(utilFunctions.formattedDateAndHour(note.updatedAt))
                                        } icon: {
                                            Image(systemName: "pencil")
                                        }
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.blue)
                                    }
                                    .frame(width: cardWidth, height: 95)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(18)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
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
        .background(Color.cardBackground)
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
