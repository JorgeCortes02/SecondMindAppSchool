import SwiftUI
import SwiftData
import Foundation

struct NoteMark: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject var modelView: NoteViewModel

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

    private let accentColor = Color.blue

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 20) {
                    headerCard(title: project?.title ?? event?.title ?? "Notas")
                        .padding(.top, 16)

                    // ✅ Siempre mostramos el picker (filtra dentro del contexto)
                    pickerBar

                    searchBar

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if modelView.noteList.isEmpty {
                                emptyNoteList
                                    .padding(.top, 12)
                            } else {
                                ForEach(modelView.noteList, id: \.id) { note in
                                    noteRow(note: note)
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                                            removal: .opacity.combined(with: .move(edge: .trailing))
                                        ))
                                }
                            }
                        }
                        .animation(.easeInOut, value: modelView.noteList)
                        .padding(.vertical, 16)
                    }
                }.refreshable {
                Task{
                        await SyncManagerDownload.shared.syncNotes(context: context)
                        modelView.loadNotes()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Spacer()
                        buttonControlMark
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 80)
                }
                .ignoresSafeArea(.keyboard)

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

    // MARK: – Picker (siempre visible)
    private var pickerBar: some View {
        HStack(spacing: 10) {
            segmentButton(title: "Todas", tag: 0)
            segmentButton(title: "Favoritas", tag: 1)
            segmentButton(title: "Archivadas", tag: 2)
        }
        .padding(15)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }

    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (modelView.selectedTab == tag)
        return Button {
            withAnimation { modelView.selectedTab = tag }
        } label: {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : accentColor)
                .frame(maxHeight: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? accentColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: – SearchBar
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
        .padding(12)
        .background(Color.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black.opacity(0.6), lineWidth: 1.2)
        )
        .cornerRadius(25)
        .padding(.horizontal)
    }

    private var buttonControlMark: some View {
         HStack(spacing: 10) {
         
             // ✅ BOTÓN +
             if #available(iOS 26.0, *) {
                 Button(action: {
                     navigateToNewNote = true
                 }) {
                     Image(systemName: "plus")
                         .font(.system(size: 28, weight: .bold))
                         .foregroundColor(.blue)
                         .padding(16)
                 }
                 .glassEffect(.clear.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                 .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                
             } else {
                 Button(action: {
                     navigateToNewNote = true
                 }) {
                     Image(systemName: "plus")
                         .font(.system(size: 28, weight: .bold))
                         .foregroundColor(.white)
                         .padding(10)
                         .background(
                             Circle()
                                 .fill(Color.blue.opacity(0.9))
                                 .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                         )
                 }
                
             }
         }
         .padding(10)
         .padding(.bottom, 60)
     }
     
    // MARK: – Empty List
    private var emptyNoteList: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.orange.opacity(0.7))

            Text("No hay notas disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }

    // MARK: – Fila de Nota (con botonera original)
    private func noteRow(note: NoteItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Fechas
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar.badge.plus")
                    Text(note.createdAt, format: .dateTime.day().month().year())
                }
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                    Text(note.updatedAt, format: .dateTime.day().month().year().hour().minute())
                }
                .font(.footnote)
                .foregroundColor(.blue)
            }

            // Proyecto y evento
            HStack(spacing: 16) {
                if let project = note.project {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .font(.callout)
                            .foregroundColor(.purple.opacity(0.9))
                        Text(project.title)
                            .font(.callout)
                            .foregroundColor(.purple.opacity(0.9))
                            .lineLimit(1)
                    }
                }

                if let event = note.event {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.callout)
                            .foregroundColor(.eventButtonColor)
                        Text(event.title)
                            .font(.callout)
                            .foregroundColor(.eventButtonColor)
                            .lineLimit(1)
                    }
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

            // Botonera original
            HStack(spacing: 20) {
                NavigationLink(destination: NoteDetailView(note: note)) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.orange))
                }

                Button {
                    withAnimation { modelView.delete(note) }
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.red))
                }

                Button {
                    withAnimation { modelView.toggleArchived(note) }
                } label: {
                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.blue))
                }

                Button {
                    withAnimation { modelView.toggleFavorite(note) }
                } label: {
                    Image(systemName: note.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(note.isFavorite ? Color.yellow : Color.gray))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            )
            .padding(.top, 4)
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
