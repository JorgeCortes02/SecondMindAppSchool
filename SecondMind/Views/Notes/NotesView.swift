import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass

    // 🔹 Entrada opcional
    var project: Project?
    var event: Event?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColorTemplate()

                VStack(alignment: .leading, spacing: 0) {
                    // ——— Header externo (igual que en EventsView, ProjectsView, etc) ———
                    Header()
                        .frame(height: 40)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                        // ——— Aquí pasamos el contexto (proyecto/evento) a NoteMark ———
                        NoteMark(project: project, event: event)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
