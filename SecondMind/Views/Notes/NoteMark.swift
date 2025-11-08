import SwiftUI
import SwiftData
import Foundation

struct NoteMark: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject var modelView: NoteViewModel
    @State private var showDeleteAlertForNote: [PersistentIdentifier: Bool] = [:]
    // Contexto de entrada
    private var project: Project?
    private var event: Event?

    init(project: Project? = nil, event: Event? = nil) {
        _modelView = StateObject(wrappedValue: NoteViewModel())
        self.project = project
        self.event = event
    }

    @State private var searchText: String = ""
    @State private var navigateToNewNote = false
    @State private var isSyncing = false
    @State private var refreshID = UUID()

    private let accentColor = Color.noteBlue

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 20) {
                    headerCard(title: project?.title ?? event?.title ?? "Notas")
                        .padding(.top, 16)

                    PickerBar(options: ["Todas", "Favoritas", "Archivadas"], selectedTab: $modelView.selectedTab)

                    searchBar

                    ScrollView {
                        // 🔁 Mantengo tu animación y transiciones
                        VStack(spacing: 16) {
                            if modelView.noteList.isEmpty {
                                emptyNoteList
                                    .padding(.top, 12)
                            } else {
                                if sizeClass == .regular {
                                    // 💻 iPad: tarjeta contenedora centrada (maxWidth 800) + grid 2 columnas
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Notas")
                                                .font(.title2.weight(.bold))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text("\(modelView.noteList.count)")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)

                                        Rectangle()
                                            .fill(Color.primary.opacity(0.1))
                                            .frame(height: 1)

                                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                                                  spacing: 16) {
                                            ForEach(modelView.noteList, id: \.id) { note in
                                                noteCardExpanded(note: note) // 👉 clicable a detalle
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 10)
                                    }
                                    .frame(maxWidth: 800)
                                    .background(Color.cardBG)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                                } else {
                                    // 📱 iPhone: tu lista original con transiciones
                                    LazyVStack(spacing: 12) {
                                        ForEach(modelView.noteList, id: \.id) { note in
                                            noteRow(note: note)
                                                .transition(.asymmetric(
                                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                                ))
                                        }
                                    }
                                    .padding(.vertical, 16)
                                }
                            }
                        }
                        .animation(.easeInOut, value: modelView.noteList)
                    }
                    .id(refreshID)
                    .refreshable {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncAll(context: context)
                            modelView.loadNotes()
                            isSyncing = false
                        }
                    }
                }
                // ✅ Mantengo tu safeAreaInset con trailing 16 como tenías
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        buttonControlMark
                    }
                   
                }
                .ignoresSafeArea(.keyboard)

                // ✅ Mantengo tu NavigationLink programático
                NavigationLink(
                    destination: destinationView,
                    isActive: $navigateToNewNote
                ) { EmptyView() }
            }
            .onAppear {
                modelView.setContext(context)
                modelView.setScope(project: project, event: event)
                modelView.loadNotes()
            }
            .onChange(of: modelView.selectedTab) { _ in
                withAnimation { modelView.loadNotes() }
            }
        }
    }

   

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Buscar notas...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .onChange(of: searchText) { newValue in
                    modelView.applySearch(newValue)
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    modelView.applySearch("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: 500) // 👈 LIMITA el ancho máximo (ajústalo a gusto)
        .background(Color.cardBG)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black.opacity(0.6), lineWidth: 1.2)
        )
        .cornerRadius(25)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center) // 👈 la centra
    }
    // MARK: – Botonera inferior (iPad: 🔄 + ➕ | iPhone: ➕)
    private var buttonControlMark: some View {
        
            
            
    glassButtonBar(funcAddButton: {navigateToNewNote = true},
                   funcSyncButton: {
                                    Task {
                                            isSyncing = true
                                            await SyncManagerDownload.shared.syncAll(context: context)
                                            modelView.loadNotes()
                                            withAnimation { refreshID = UUID() }
                                            isSyncing = false
                                        }},
                   funcCalendarButton: {},
                   color: accentColor,
                   selectedTab: $modelView.selectedTab,
                   isSyncing: $isSyncing)
            
    }
    // MARK: – Empty List (igual)
    private var emptyNoteList: some View {
   
            EmptyList(color: accentColor, textIcon: "note.text")
            
    }

    // MARK: – Fila de Nota (versión móvil)
    private func noteRow(note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 🔹 Fechas
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.plus")
                    Text(utilFunctions.formattedDateShort(note.createdAt))
                }
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                    Text(utilFunctions.formattedDateAndHour(note.updatedAt))
                }
                .font(.footnote)
                .foregroundColor(Color.noteBlue)
            }

            // 🔹 Proyecto y evento (ambos si existen)
            HStack(spacing: 12) {
                if let project = note.project {
                    Label(project.title, systemImage: "folder.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.purple)
                        .lineLimit(1)
                }

                if let event = note.event {
                    Label(event.title, systemImage: "calendar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.eventButtonColor)
                        .lineLimit(1)
                }
            }

            // 🔹 Título
            Text(note.title.isEmpty ? "Sin título" : note.title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)

            // 🔹 Contenido
            if let content = note.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                    .truncationMode(.tail)
            }

            // 🔹 Nueva botonera reutilizable
            noteActionBar(note: note)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
    // MARK: – Tarjeta expandida (versión iPad)
    private func noteCardExpanded(note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // 🔹 Fechas (creación + edición)
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.plus")
                    Text(utilFunctions.formattedDateShort(note.createdAt))
                }
                .font(.caption)
                .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                    Text(utilFunctions.formattedDateAndHour(note.updatedAt))
                }
                .font(.caption)
                .foregroundColor(Color.noteBlue)
            }

            // 🔹 Proyecto / Evento
            HStack(spacing: 12) {
                if let project = note.project {
                    Label(project.title, systemImage: "folder.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.purple)
                        .lineLimit(1)
                }

                if let event = note.event {
                    Label(event.title, systemImage: "calendar")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.eventButtonColor)
                        .lineLimit(1)
                }
            }

            // 🔹 Título
            Text(note.title.isEmpty ? "Sin título" : note.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            // 🔹 Contenido
            if let content = note.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .truncationMode(.tail)
            }

            // 🔹 Botonera reutilizable (idéntica a la de móvil)
            noteActionBar(note: note)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
    
    // MARK: – Botonera reutilizable (con confirmación y sincronización de una sola nota)
    private func noteActionBar(note: NoteItem) -> some View {
        let noteID = note.persistentModelID
        let isShowingAlert = Binding(
            get: { showDeleteAlertForNote[noteID] ?? false },
            set: { showDeleteAlertForNote[noteID] = $0 }
        )

        return HStack(spacing: 20) {
            // ✏️ Editar
            NavigationLink(destination: NoteDetailView(note: note)) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.orange))
            }

            // 🗑️ Eliminar (con confirmación + sync individual)
            Button {
                isShowingAlert.wrappedValue = true
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.red))
            }
            .alert("Eliminar nota", isPresented: isShowingAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    Task {
                        // 🔸 Elimina localmente
                        withAnimation(.easeInOut) {
                            modelView.delete(note)
                        }

                        // 🔸 Sincroniza solo esa nota
                        await SyncManagerUpload.shared.deleteNote(note: note)

                        // 🔸 Recarga notas
                        withAnimation(.easeInOut) {
                            modelView.loadNotes()
                        }

                        showDeleteAlertForNote[noteID] = false
                    }
                }
            } message: {
                Text("¿Seguro que deseas eliminar esta nota? Se eliminará también del servidor.")
            }

            // 📦 Archivar (toggle + sync individual)
            Button {
                Task {
                    withAnimation(.easeInOut) {
                        modelView.toggleArchived(note)
                    }

                    // 🔸 Sincroniza esa nota
                    await SyncManagerUpload.shared.uploadNote(note: note)

                    // 🔸 Refresca lista local
                    withAnimation(.easeInOut) {
                        modelView.loadNotes()
                    }
                }
            } label: {
                Image(systemName: note.isArchived ? "archivebox.fill" : "archivebox")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.noteBlue))
            }

            // ⭐️ Favorito (toggle + sync individual)
            Button {
                Task {
                    withAnimation(.easeInOut) {
                        modelView.toggleFavorite(note)
                    }

                    // 🔸 Sincroniza esa nota
                    await SyncManagerUpload.shared.uploadNote(note: note)

                    // 🔸 Refresca lista local
                    withAnimation(.easeInOut) {
                        modelView.loadNotes()
                    }
                }
            } label: {
                Image(systemName: note.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(note.isFavorite ? Color.yellow : Color.gray))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .padding(.top, 6)
    }
    // MARK: – Destino de nueva nota (mantengo tu lógica)
    @ViewBuilder
    private var destinationView: some View {
        if let project {
            NoteDetailView(note: nil, project: project)
        } else if let event {
            NoteDetailView(note: nil, event: event)
        } else {
            NoteDetailView(note: nil)
        }
    }
}
