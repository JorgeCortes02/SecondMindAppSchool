import Foundation
import SwiftData
import SwiftUI

@MainActor
final class NoteDetailViewModel: ObservableObject {
    // Estado UI
    @Published var isEditing: Bool = true
    @Published var isListMode: Bool = false
    
    // Modelo principal (persistente)
    @Published var note: NoteItem
    
    // Datos para pickers
    @Published var projects: [Project] = []
    @Published var events: [Event] = []
    
    // Flags para bloquear pickers
    @Published var lockProject: Bool = false
    @Published var lockEvent: Bool = false
    
    // Drafts temporales (UI)
    @Published var draftTitle: String
    @Published var draftContent: String
    @Published var draftProject: Project? {
        didSet { handleProjectChange() }
    }
    @Published var draftEvent: Event? {
        didSet { handleEventChange() }
    }
    
    // Gestión
    private var context: ModelContext?
    private(set) var isNew: Bool
    
    init(note: NoteItem?, project: Project?, event: Event?) {
        if let existing = note {
            self.note = existing
            self.isNew = false
            
            self.draftTitle = existing.title
            self.draftContent = existing.content ?? ""
            self.draftProject = existing.project
            self.draftEvent = existing.event
            
        } else {
            let newNote = NoteItem(
                title: "",
                content: "",
                createdAt: Date(),
                updatedAt: Date(),
                isFavorite: false,
                isArchived: false
            )
            self.note = newNote
            self.isNew = true
            
            self.draftTitle = ""
            self.draftContent = ""
            self.draftProject = project
            self.draftEvent = event
            
            if let event {
                self.draftEvent = event
                self.lockEvent = true
                
                if let projectFromEvent = event.project {
                    self.draftProject = projectFromEvent
                    self.lockProject = true
                } else {
                    self.lockProject = true // evento sin proyecto también bloquea
                }
            }
            
            if let project {
                self.draftProject = project
                self.lockProject = true
            }
        }
    }
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }
    
    func loadPickers() {
        guard let context else { return }
        do {
            projects = try context.fetch(FetchDescriptor<Project>())
            events   = try context.fetch(FetchDescriptor<Event>())
        } catch {
            print("❌ Error cargando pickers: \(error)")
        }
    }
    
    func insertListMarker() {
        isListMode.toggle()
        guard isListMode else { return }
        
        var text = draftContent
        if text.isEmpty || text.hasSuffix("\n") {
            text += "• "
        } else if !text.hasSuffix("• ") {
            text += "\n• "
        }
        draftContent = text
    }
    
    func insertHeading(_ prefix: String) {
        draftContent = prefix + draftContent
    }
    
    func downloadProjectsAndEvents() {
        if let context {
            events = HomeApi.downdloadEventsFrom(context: context)
            projects = HomeApi.downdloadProjectsFrom(context: context)
        }
    }
    
    /// ✅ Cuando se cambia el evento seleccionado
    private func handleEventChange() {
        guard let selectedEvent = draftEvent else {
            // Si se elimina el evento, desbloqueamos el proyecto
            lockProject = false
            return
        }
        
        if let linkedProject = selectedEvent.project {
            // El evento tiene proyecto → lo asignamos y bloqueamos
            draftProject = linkedProject
            lockProject = true
        } else {
            // El evento no tiene proyecto → limpiamos y bloqueamos
            draftProject = nil
            lockProject = true
        }
    }
    
    /// ✅ Cuando se cambia el proyecto seleccionado
    func handleProjectChange() {
        guard let context else { return }
        
        if let project = draftProject {
            // Actualizar lista de eventos de ese proyecto
            events = HomeApi.downdloadEventsFromProject(project: project, context: context)
            
            // Si el evento actual no pertenece al proyecto, lo limpiamos
            if let currentEvent = draftEvent, currentEvent.project?.id != project.id {
                draftEvent = nil
            }
        } else {
            // Sin proyecto → mostrar todos los eventos
            events = HomeApi.downdloadEventsFrom(context: context)
        }
    }
    
    func saveNote() {
        guard let context else {
            print("❌ context es nil")
            return
        }
        
        note.title = draftTitle.isEmpty ? "Sin título" : draftTitle
        note.content = draftContent
        note.project = draftProject
        note.event = draftEvent
        note.updatedAt = Date()
        
        if isNew {
            context.insert(note)
            if let p = note.project { p.notes.append(note) }
            if let e = note.event   { e.notes.append(note) }
            isNew = false
        }
        
        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadNote(note: note)
            }
        } catch {
            print("❌ Error al guardar la nota: \(error)")
        }
    }
}
