import Foundation
import SwiftData

@MainActor
class NoteViewModel: ObservableObject {
    // Lista final que consume la vista
    @Published var noteList: [NoteItem] = []
    @Published var selectedTab: Int = 0            // 0: Todas, 1: Favoritas, 2: Archivadas
    @Published var searchQuery: String = ""

    private var context: ModelContext?

    // Contexto de filtrado: global, por proyecto, o por evento
    enum Scope {
        case all
        case project(Project)
        case event(Event)
    }
    private var scope: Scope = .all

    // Base sin search ni tab (según scope)
    private var baseNotes: [NoteItem] = []

    // MARK: - Setup
    func setContext(_ context: ModelContext) {
        self.context = context
    }

    func setScope(project: Project? = nil, event: Event? = nil) {
        if let project { scope = .project(project) }
        else if let event { scope = .event(event) }
        else { scope = .all }
    }

    // MARK: - Carga y filtrado
    func loadNotes() {
        // 1) Construye la base según scope
        switch scope {
        case .all:
            guard let context else { noteList = []; return }
            switch selectedTab {
            case 0: // Todas (no archivadas)
                baseNotes = HomeApi.downloadActiveNotes(context: context)
            case 1: // Favoritas (no archivadas)
                baseNotes = HomeApi.downloadFavoritesNotes(context: context)
            case 2: // Archivadas
                baseNotes = HomeApi.downloadArchivedNotes(context: context)
            default:
                baseNotes = []
            }

        case .project(let project):
            // Partimos del array ya existente en el modelo
            let source = project.notes
            switch selectedTab {
            case 0: baseNotes = source.filter { $0.isArchived == false }
            case 1: baseNotes = source.filter { $0.isFavorite && !$0.isArchived }
            case 2: baseNotes = source.filter { $0.isArchived }
            default: baseNotes = source
            }

        case .event(let event):
            let source = event.notes
            switch selectedTab {
            case 0: baseNotes = source.filter { $0.isArchived == false }
            case 1: baseNotes = source.filter { $0.isFavorite && !$0.isArchived }
            case 2: baseNotes = source.filter { $0.isArchived }
            default: baseNotes = source
            }
        }

        // 2) Aplica búsqueda
        applySearch(searchQuery)
    }

    func applySearch(_ query: String) {
        searchQuery = query
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            noteList = baseNotes.sorted { $0.updatedAt > $1.updatedAt }
            return
        }

        let q = query.lowercased()
        noteList = baseNotes.filter { note in
            let title = note.title.lowercased()
            let content = (note.content ?? "").lowercased()
            return title.contains(q) || content.contains(q)
        }
        .sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - Acciones
    func toggleFavorite(_ note: NoteItem) {
        note.isFavorite.toggle()
        note.updatedAt = Date()
        saveAndRefresh()
    }

    func toggleArchived(_ note: NoteItem) {
        note.isArchived.toggle()
        note.updatedAt = Date()
        saveAndRefresh()
    }

    func delete(_ note: NoteItem) {
        guard let context else { return }
        context.delete(note)
        saveAndRefresh()
    }

    private func saveAndRefresh() {
        guard let context else { return }
        do {
            try context.save()
        } catch {
            print("❌ Error guardando cambios: \(error)")
        }
        // Recalcula base + search y deja que la vista anime la desaparición
        loadNotes()
    }
}
