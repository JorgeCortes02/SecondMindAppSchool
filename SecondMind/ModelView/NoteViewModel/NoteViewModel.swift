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
           
            switch selectedTab {
                
                case 0:
                
                noteList = HomeApi.downloadActiveNotes(context: context)
                    break;
                case 1:
                noteList = HomeApi.downloadFavoritesNotes(context: context)
                    break ;
            case 2:
                noteList = HomeApi.downloadArchivedNotes(context: context)
                break;
            
            default :
                break;
            }
            
            
        }
       
    }


    func applySearch(_ query: String) {
        guard let context else { return }
        
        if query.isEmpty {
            loadNotes()
        } else {
            switch selectedTab {
            case 0:
                noteList = HomeApi.searchActiveNotes(context: context, query: query)
            case 1:
                noteList = HomeApi.searchFavoritesNotes(context: context, query: query)
            case 2:
                noteList = HomeApi.searchArchivedNotes(context: context, query: query)
            default:
                noteList = []
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
