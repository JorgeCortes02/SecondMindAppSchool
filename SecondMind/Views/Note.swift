import SwiftUI

struct NoteCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Cabecera con fecha fija
            Text("14 de septiembre de 2025")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Título de ejemplo
            Text("Idea para el proyecto")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Contenido de ejemplo
            Text("Explorar cómo integrar SwiftData con el backend y permitir edición offline de las notas. También añadir etiquetas.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Botón de acción (editar)
            HStack {
                Spacer()
                Button(action: {
                    print("Editar nota")
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.orange)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(colors: [Color.blue.opacity(0.2), Color.pink.opacity(0.2)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            NoteCardView()
        }
    }
}
