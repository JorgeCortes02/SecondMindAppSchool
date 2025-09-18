import SwiftUI

struct NoteMark: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var searchText = ""

    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.noteList
        } else {
            return viewModel.noteList.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.15), Color.pink.opacity(0.15)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                
                // MARK: - Barra de búsqueda
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar notas...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                .padding(.horizontal)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredNotes) { note in
                            noteRow(note: note)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, 10)
                }
            }

            // Botón flotante nueva nota
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("➕ Crear nueva nota")
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .onAppear { viewModel.loadNotes() }
    }

    // MARK: - Tarjeta de nota estilo Post-it
    private func noteRow(note: Note) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)

            Text(note.title)
                .font(.headline)
                .foregroundColor(.black)

            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(5)
                .multilineTextAlignment(.leading)

            HStack {
                Spacer()
                Button(action: {
                    print("✏️ Editar nota \(note.id)")
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(noteColor(for: note.id))
        )
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }

    // MARK: - Colores tipo Post-it
    private func noteColor(for id: Int) -> Color {
        let colors: [Color] = [
            Color.yellow.opacity(0.8),
            Color.green.opacity(0.7),
            Color.orange.opacity(0.7),
            Color.pink.opacity(0.7)
        ]
        return colors[id % colors.count]
    }
}

