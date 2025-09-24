import Foundation
import SwiftData
import SwiftUI

@MainActor
final class NoteDetailViewModel: ObservableObject {
    // Estado UI
    @Published var isEditing: Bool = true
    @Published var isListMode: Bool = false
    
    // Modelo principal
    @Published var note: NoteItem
    
    // Datos para pickers
    @Published var projects: [Project] = []
    @Published var events: [Event] = []
    
    // Gestión
    private var context: ModelContext?
    private(set) var isNew: Bool
    
    init(note: NoteItem?, project: Project?, event: Event?) {
        if let existing = note {
            self.note = existing
            self.isNew = false
        } else {
            self.note = NoteItem(
                title: "",
                content: "",
                createdAt: Date(),
                updatedAt: Date(),
                isFavorite: false,
                isArchived: false
            )
            self.isNew = true
            // Si se abre desde un proyecto/evento, lo asignamos por defecto
            self.note.project = project
            self.note.event = event
        }
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    // Carga de listas para pickers (SwiftData directo para que compile ya)
    func loadPickers() {
        guard let context else { return }
        do {
            projects = try context.fetch(FetchDescriptor<Project>())
            events   = try context.fetch(FetchDescriptor<Event>())
        } catch {
            print("❌ Error cargando pickers: \(error)")
        }
    }
    
    // Botón "• Lista"
    func insertListMarker() {
        isListMode.toggle()
        guard isListMode else { return }
        
        var text = note.content ?? ""
        if text.isEmpty || text.hasSuffix("\n") {
            text += "• "
        } else if !text.hasSuffix("• ") {
            // Si no estaba en bullet, lo empezamos
            text += "\n• "
        }
        note.content = text
    }
    
    // Botones H1 / H2
    func insertHeading(_ prefix: String) {
        let current = note.content ?? ""
        note.content = prefix + current
    }
    
    
    func downloadProjectsAndEvents(){
        
        if let context {
            
            events = HomeApi.downdloadEventsFrom(context: context)
            projects = HomeApi.downdloadProjectsFrom(context: context)
        }
       
    }
    func handleProjectChange() {
        guard let context else { return }

        if let project = note.project {
  
            events = HomeApi.downdloadEventsFromProject(project: project, context: context)
        } else {
            events = HomeApi.downdloadEventsFrom(context: context)
        }
    }
    // Guardado
    func saveNote() {
        guard let context else { return }
        
        note.updatedAt = Date()
        
        if isNew {
            context.insert(note)
            // Mantener relaciones si existen
            if let p = note.project { p.notes.append(note) }
            if let e = note.event   { e.notes.append(note) }
            isNew = false
        }
        
        do {
            try context.save()
        } catch {
            print("❌ Error al guardar la nota: \(error)")
        }
    }
}
