import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    @StateObject private var viewModel: NoteDetailViewModel

    init(note: NoteItem? = nil, project: Project? = nil, event: Event? = nil) {
        _viewModel = StateObject(
            wrappedValue: NoteDetailViewModel(
                note: note,
                project: project,
                event: event
            )
        )
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Header
                    headerCard
                        .padding(.top, 20)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)

                    // MARK: - Fechas
                    VStack(spacing: 10) {
                        Divider().padding(.vertical, 6)

                        HStack(spacing: 12) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Creado")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(utilFunctions.formattedDateShort(viewModel.note.createdAt))
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            } icon: {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "calendar.badge.plus")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Última edición")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(utilFunctions.formattedDateShort(viewModel.note.updatedAt ?? viewModel.note.createdAt))
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                            } icon: {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.15))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "pencil")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 20)
                    }

                    // MARK: - Proyecto / Evento
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Proyecto")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Picker("Proyecto", selection: $viewModel.draftProject) {
                                Text("Sin proyecto").tag(nil as Project?)
                                ForEach(viewModel.projects, id: \.self) { project in
                                    Text(project.title).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                            .disabled(viewModel.lockProject)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Evento")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Picker("Evento", selection: $viewModel.draftEvent) {
                                Text("Sin evento").tag(nil as Event?)
                                ForEach(viewModel.events, id: \.self) { event in
                                    Text(event.title).tag(event as Event?)
                                }
                            }
                            .pickerStyle(.menu)
                            .disabled(viewModel.lockEvent)
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Título
                    if viewModel.isEditing {
                        TextField("Escribe un título", text: $viewModel.draftTitle)
                            .font(.system(size: 28, weight: .bold))
                            .padding(.horizontal)
                    } else {
                        Text(viewModel.draftTitle.isEmpty ? "Sin título" : viewModel.draftTitle)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .onTapGesture { viewModel.isEditing = true }
                    }

                    Divider()

                    // MARK: - Contenido
                    if viewModel.isEditing {
                        TextEditor(text: $viewModel.draftContent)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal)
                            .frame(minHeight: 300)
                    } else {
                        ScrollView {
                            if !viewModel.draftContent.isEmpty {
                                Text(viewModel.draftContent)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                            } else {
                                Text("Escribe algo...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(minHeight: 300)
                        .onTapGesture { viewModel.isEditing = true }
                    }
                }
                .padding(.bottom, 40)
                // 📏 FORMATO RESPONSIVE
                .frame(maxWidth: sizeClass == .regular ? 800 : .infinity)
                .padding(.horizontal, sizeClass == .regular ? 24 : 16)
                .padding(.top, 20)
                .background(
                    Group {
                        if sizeClass == .regular {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.95))
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                        } else {
                            Color.clear
                        }
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        // MARK: - Toolbar
        .toolbar {
            // Botón OK
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isEditing {
                    Button("OK") {
                        viewModel.saveNote()
                        viewModel.isEditing = false
                    }
                }
            }

            // Botón Lista
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if viewModel.isEditing {
                    Button("• Lista") { viewModel.insertListMarker() }
                }
            }
        }
        .onAppear {
            viewModel.setContext(context)
            viewModel.downloadProjectsAndEvents()
            if viewModel.draftProject != nil {
                viewModel.handleProjectChange()
            }
        }
        .onChange(of: viewModel.draftProject) { _ in
            viewModel.handleProjectChange()
        }
    }

    private var headerCard: some View {
        Text("Detalles de tu nota")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.taskButtonColor)
            .padding()
    }
}
