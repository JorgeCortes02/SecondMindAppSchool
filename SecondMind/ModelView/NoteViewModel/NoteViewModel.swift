import SwiftUI
import SwiftData

@MainActor
class NoteViewModel: ObservableObject {
    @Published var noteList: [Note] = []
    private var context: ModelContext?

    func setContext(_ context: ModelContext) { self.context = context }

    func loadNotes() {
        guard noteList.isEmpty else { return }

        noteList = [
            Note(id: 1,
                 title: "Lista de la compra",
                 content: "🍎 Manzanas\n🥛 Leche\n🥚 Huevos\n🥖 Pan integral",
                 date: Date().addingTimeInterval(-3600*5),
                 event: nil),

            Note(id: 2,
                 title: "Ideas app",
                 content: "💡 Añadir modo oscuro\n📌 Mejorar login con biometría\n✨ Nueva pantalla de notas rápidas",
                 date: Date().addingTimeInterval(-3600*24),
                 event: nil),

            Note(id: 3,
                 title: "Cita médica",
                 content: "Recordar cita con el dentista el jueves a las 16:30",
                 date: Date().addingTimeInterval(-3600*2),
                 event: nil),

            Note(id: 4,
                 title: "Tareas trabajo",
                 content: "✅ Revisar PR\n✅ Preparar presentación\n🔄 Llamar a cliente",
                 date: Date(),
                 event: nil)
        ]

        // ✅ Ordenar por fecha (más recientes arriba)
        noteList.sort { $0.date > $1.date }
    }

    func addNote(_ note: Note) {
        noteList.append(note)
        noteList.sort { $0.date > $1.date }
    }
}
