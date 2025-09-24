//
//  NotesCarruselModelView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 24/9/25.
//

import Foundation
import SwiftData

@MainActor
class NotesCarrouselModelView: ObservableObject {
    @Published var notes: [NoteItem] = []
    private var context: ModelContext?

    init(context: ModelContext? = nil) {
        self.context = context
    }

    func setContext(_ context: ModelContext) {
        self.context = context
    }

    // 🔹 Cargar notas de un proyecto
    func loadNotes(for project: Project) {
        notes = project.notes.filter { !$0.isArchived }
    }

    // 🔹 Cargar notas de un evento
    func loadNotes(for event: Event) {
        notes = event.notes.filter { !$0.isArchived }
    }
}
