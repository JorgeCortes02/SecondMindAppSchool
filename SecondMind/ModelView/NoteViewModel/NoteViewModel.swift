import Foundation
import SwiftData

@MainActor
class NoteViewModel: ObservableObject {
    @Published var noteList: [NoteItem] = []
    @Published var filteredList: [NoteItem] = []
    @Published var selectedTab: Int = 0
    private var context: ModelContext?

    func setContext(_ context: ModelContext) {
        self.context = context
    }

    func loadNotes() {
        if let context{
            
            noteList = HomeApi.downloadNotes(context: context)
        }
       
    }

    func loadByTab(tab: Int) {
        switch tab {
        case 1: // Favoritas
            filteredList = noteList.filter { $0.isFavorite }
        case 2: // Archivadas
            filteredList = noteList.filter { $0.isArchived }
        default: // Todas
            filteredList = noteList
        }
    }

    func applySearch(_ query: String, tab: Int) {
        loadByTab(tab: tab)
        if !query.isEmpty {
            filteredList = filteredList.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.content ?? "").localizedCaseInsensitiveContains(query)
            }
        }
    }

    func toggleFavorite(_ note: NoteItem) {
        note.isFavorite.toggle()
        note.updatedAt = Date()
        saveContext()
    }

    func toggleArchived(_ note: NoteItem) {
        note.isArchived.toggle()
        note.updatedAt = Date()
        saveContext()
    }

    func delete(_ note: NoteItem) {
        guard let context else { return }
        context.delete(note)
        saveContext()
    }

    private func saveContext() {
        guard let context else { return }
        do {
            try context.save()
            loadNotes()
        } catch {
            print("❌ Error guardando cambios: \(error)")
        }
    }
}
