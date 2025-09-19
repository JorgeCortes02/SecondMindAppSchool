import SwiftUI
import SwiftData
import AVFoundation
struct NoteMark: View {
    @StateObject private var viewModel = NoteViewModel()
    @Environment(\.modelContext) private var context
    
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
        VStack(spacing: 16) {
            // Header
            headerCard(title: "Notas")
                .padding(.top, 16)
            
            // Barra de búsqueda debajo del header
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar notas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius:  25)
                    .stroke(Color.black.opacity(0.6), lineWidth: 1.2) // 👈 borde oscuro
            )
            .cornerRadius(25)
            .padding(.horizontal)
            
            // Lista de notas
            ScrollView {
                VStack(spacing: 20) {
                    if filteredNotes.isEmpty {
                        emptyNoteList
                    } else {
                        ForEach(filteredNotes.sorted(by: { $0.date > $1.date })) { note in
                            noteRow(note: note)
                        }
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                buttonControlMark
            }
            .padding(.trailing, 16)
            .padding(.bottom, 80)
        }
        .onAppear {
            viewModel.setContext(context)
            viewModel.loadNotes()
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Botón flotante
    private var buttonControlMark: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(14)
                .background(Circle().fill(Color.blue))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        }
        .padding(10)
    }
    
    // MARK: - Lista vacía
    private var emptyNoteList: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.orange.opacity(0.7))
            
            Text("No hay notas disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }
}
// 🔹 Función auxiliar para activar cortes con guiones
func hyphenatedText(_ string: String) -> AttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.hyphenationFactor = 1.0 // activa guiones automáticos
    
    let attributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: paragraphStyle
    ]
    
    return AttributedString(NSAttributedString(string: string, attributes: attributes))
}

private func noteRow(note: Note) -> some View {
    HStack(spacing: 0) {
        // Contenido de la nota
        VStack(alignment: .leading, spacing: 10) {
            Text(note.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(note.title)
                .font(.headline)
                .foregroundColor(.taskButtonColor)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(note.content)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.black.opacity(0.85))
                .lineSpacing(6)
                .lineLimit(5)
                .truncationMode(.tail)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
        // Franja lateral con botones
        VStack(spacing: 12) {
            Button(action: {
                print("✏️ Editar \(note.id)")
            }) {
                Label("Editar", systemImage: "square.and.pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            
            Button(action: {
                print("🗑 Borrar \(note.id)")
            }) {
                Label("Borrar", systemImage: "trash.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            Button(action: {
                speakText(note.content)
            }) {
                Label("Leer", systemImage: "speaker.wave.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button(action: {
                speakNote(title: note.title, content: note.content)
            }) {
                Label("Todo", systemImage: "speaker.wave.3.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical)
        .frame(width: 110) // ancho fijo para la franja
        .background(Color.gray.opacity(0.1))
    }
    .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    )
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.black.opacity(0.2), lineWidth: 1)
    )
    .padding(.horizontal)
}




func speakNote(title: String, content: String) {
    let textToRead = "\(title). \(content)"
    let utterance = AVSpeechUtterance(string: textToRead)
    utterance.voice = AVSpeechSynthesisVoice(language: "es-ES") // Español
    utterance.rate = 0.48 // velocidad natural
    
    let synthesizer = AVSpeechSynthesizer()
    synthesizer.speak(utterance)
}

func speakText(_ text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
    utterance.rate = 0.48
    AVSpeechSynthesizer().speak(utterance)
}
