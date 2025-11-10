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
    private let fieldBG = Color(red: 248/255, green: 248/255, blue: 250/255)

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    VStack(spacing: 0) {
                        VStack(spacing: 26) {
                            
                            // Cabecera visual coherente
                        
                            headerCard(title: project?.title ?? event?.title ?? "Notas", accentColor: accentColor, sizeClass: sizeClass)
                                .padding(.top, 8)
                            
                            // Selector superior
                            PickerBar(options: ["Todas", "Favoritas", "Archivadas"], selectedTab: $modelView.selectedTab)
                            
                            // Barra de búsqueda
                            searchBar
                            
                            // Contenido principal
                            VStack(spacing: 18) {
                                if modelView.noteList.isEmpty {
                                    emptyNoteList
                                        .frame(maxHeight: .infinity)
                                } else {
                                    GeometryReader { scrollGeo in
                                        ScrollView {
                                            VStack(alignment: .leading, spacing: 0) {
                                                if sizeClass == .regular {
                                                    // iPad: grid 2 columnas
                                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                                        ForEach(modelView.noteList, id: \.id) { note in
                                                            noteCardExpanded(note: note)
                                                        }
                                                    }
                                                    .padding(.horizontal, 20)
                                                } else {
                                                    // iPhone: lista vertical
                                                    LazyVStack(spacing: 12) {
                                                        ForEach(modelView.noteList, id: \.id) { note in
                                                            noteRow(note: note)
                                                        }
                                                    }
                                                    .padding(.horizontal, 16)
                                                }
                                                
                                                Spacer(minLength: 0)
                                            }
                                            .frame(minHeight: scrollGeo.size.height, alignment: .top)
                                            .padding(.bottom, 80)
                                        }.clipShape(RoundedRectangle(cornerRadius: 36))
                                        .animation(.easeInOut, value: modelView.noteList)
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                            .padding(.top, 10)
                        }
                        .padding(.top, 26)
                        .padding(.horizontal, 5)
                        .frame(maxWidth: 1200)
                        .background(
                            RoundedRectangle(cornerRadius: 36)
                                .fill(Color(red: 0.97, green: 0.96, blue: 1.0))
                                .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal, 10)
                        .padding(.top, 20)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.bottom, sizeClass == .regular ?  geo.safeAreaInsets.bottom + 20 : geo.safeAreaInsets.bottom + 100)
                    .id(refreshID)
                    .refreshable {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncAll(context: context)
                            modelView.loadNotes()
                            isSyncing = false
                        }
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .onAppear {
                        modelView.setContext(context)
                        modelView.setScope(project: project, event: event)
                        modelView.loadNotes()
                    }
                    .onChange(of: modelView.selectedTab) { _ in
                        withAnimation { modelView.loadNotes() }
                    }
                    
                    // Botón flotante sobre el contenido
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            buttonControlMark
                        }
                    }
                    .ignoresSafeArea()
                    
                    // NavigationLink programático
                    NavigationLink(
                        destination: destinationView,
                        isActive: $navigateToNewNote
                    ) { EmptyView() }
                }
            }
        }
    }

   
    // MARK: – Barra de búsqueda
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
        .frame(maxWidth: 500)
        .background(fieldBG)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black.opacity(0.6), lineWidth: 1.2)
        )
        .cornerRadius(25)
        .padding(.horizontal, 20)
    }
    
    // MARK: – Botonera inferior
    private var buttonControlMark: some View {
        glassButtonBar(
            funcAddButton: { navigateToNewNote = true },
            funcSyncButton: {
                Task {
                    isSyncing = true
                    await SyncManagerDownload.shared.syncAll(context: context)
                    modelView.loadNotes()
                    withAnimation { refreshID = UUID() }
                    isSyncing = false
                }
            },
            funcCalendarButton: {},
            color: accentColor,
            selectedTab: $modelView.selectedTab,
            isSyncing: $isSyncing
        )
    }
    
    // MARK: – Empty List
    private var emptyNoteList: some View {
        EmptyList(color: accentColor, textIcon: "note.text")
    }

    // MARK: – Fila de Nota (versión móvil)
    private func noteRow(note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Fechas
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

            // Proyecto y evento
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

            // Título
            Text(note.title.isEmpty ? "Sin título" : note.title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)

            // Contenido
            if let content = note.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(5)
                    .truncationMode(.tail)
            }

            // Botonera
            noteActionBar(note: note)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .trailing))
        ))
    }
    
    // MARK: – Tarjeta expandida (versión iPad)
    private func noteCardExpanded(note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Fechas
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

            // Proyecto / Evento
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

            // Título
            Text(note.title.isEmpty ? "Sin título" : note.title)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            // Contenido
            if let content = note.content, !content.isEmpty {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(4)
                    .truncationMode(.tail)
            }

            // Botonera
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
    
    // MARK: – Botonera reutilizable
    private func noteActionBar(note: NoteItem) -> some View {
        let noteID = note.persistentModelID
        let isShowingAlert = Binding(
            get: { showDeleteAlertForNote[noteID] ?? false },
            set: { showDeleteAlertForNote[noteID] = $0 }
        )

        return HStack(spacing: 20) {
            // Editar
            NavigationLink(destination: NoteDetailView(note: note)) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Circle().fill(Color.orange))
            }

            // Eliminar
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
                        withAnimation(.easeInOut) {
                            modelView.delete(note)
                        }
                        await SyncManagerUpload.shared.deleteNote(note: note)
                        withAnimation(.easeInOut) {
                            modelView.loadNotes()
                        }
                        showDeleteAlertForNote[noteID] = false
                    }
                }
            } message: {
                Text("¿Seguro que deseas eliminar esta nota? Se eliminará también del servidor.")
            }

            // Archivar
            Button {
                Task {
                    withAnimation(.easeInOut) {
                        modelView.toggleArchived(note)
                    }
                    await SyncManagerUpload.shared.uploadNote(note: note)
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

            // Favorito
            Button {
                Task {
                    withAnimation(.easeInOut) {
                        modelView.toggleFavorite(note)
                    }
                    await SyncManagerUpload.shared.uploadNote(note: note)
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
    
    // MARK: – Destino de nueva nota
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
