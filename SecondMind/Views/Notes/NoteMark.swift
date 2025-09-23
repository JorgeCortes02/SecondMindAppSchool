import SwiftUI
import SwiftData
import Foundation

struct NoteMark: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject var modelView: NoteViewModel

    init() {
        _modelView = StateObject(wrappedValue: NoteViewModel())
    }

    @State private var searchText: String = ""
    @State private var readyToShowNotes: Bool = false
    @State private var navigateToNewNote = false   // 👈 estado para NavigationLink

    private let accentColor = Color.blue

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 20) {
                    headerCard(title: "Notas")
                        .padding(.top, 16)

                    pickerBar
                    searchBar

                    ScrollView {
                        VStack(spacing: 20) {
                            if modelView.noteList.isEmpty {
                                emptyNoteList
                            } else if readyToShowNotes {
                                notesList
                            }
                        }
                        .padding(.vertical, 16)
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
                    destination: NoteDetailView(note: nil),
                    isActive: $navigateToNewNote
                ) { EmptyView() }
            }
            .onAppear {
                modelView.setContext(context)
                modelView.loadNotes()
                readyToShowNotes = true
            }
            .onChange(of: modelView.selectedTab) { newTab in
                withAnimation {
                    modelView.loadNotes()
                    modelView.applySearch(searchText, tab: newTab)
                    readyToShowNotes = true
                }
            }
        }
    }

    // MARK: – Picker
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
                    modelView.applySearch(newValue, tab: modelView.selectedTab)
                }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    modelView.applySearch("", tab: modelView.selectedTab)
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

    // MARK: – Floating Button
    private var buttonControlMark: some View {
        Button {
            navigateToNewNote = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(14)
                .background(Circle().fill(accentColor))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        }
        .padding(10)
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

    // MARK: – Notes List
    private var notesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(modelView.noteList, id: \.id) { note in
                NavigationLink(destination: NoteDetailView(note: note)) {
                    noteRow(note: note)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: – Note Row
    private func noteRow(note: NoteItem) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Creada: \(note.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Capsule())
                        .foregroundColor(.secondary)

                    Text("Editada: \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundColor(.blue)
                }

                if let project = note.project {
                    Label("Proyecto: \(project.title)", systemImage: "folder.fill")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.8))
                }
                if let event = note.event {
                    Label("Evento: \(event.title)", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                }

                Text(note.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.top, 4)

                if let content = note.content {
                    Text(content)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .lineLimit(4)
                        .truncationMode(.tail)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                NavigationLink(destination: NoteDetailView(note: note)) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.orange)
                        .clipShape(Circle())
                }

                Button {
                    modelView.delete(note)
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.red)
                        .clipShape(Circle())
                }

                Button {
                    modelView.toggleArchived(note)
                } label: {
                    Image(systemName: "archivebox.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                Button {
                    modelView.toggleFavorite(note)
                } label: {
                    Image(systemName: note.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
            }
            .padding(.vertical)
            .frame(width: 70)
            .background(Color.gray.opacity(0.08))
        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.gray.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}
