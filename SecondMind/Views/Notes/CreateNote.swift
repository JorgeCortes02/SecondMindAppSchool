import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
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
            BackgroundColorTemplate()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                headerCard(title: "Tu nota")
                    .padding(.top, 16)

                // --- Pickers en HStack ---
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Proyecto")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker("Proyecto", selection: Binding(
                            get: { viewModel.note.project },
                            set: { viewModel.note.project = $0 }
                        )) {
                            Text("Sin proyecto").tag(nil as Project?)
                            ForEach(viewModel.projects, id: \.self) { project in
                                Text(project.title).tag(project as Project?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Evento")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Picker("Evento", selection: Binding(
                            get: { viewModel.note.event },
                            set: { viewModel.note.event = $0 }
                        )) {
                            Text("Sin evento").tag(nil as Event?)
                            ForEach(viewModel.events, id: \.self) { event in
                                Text(event.title).tag(event as Event?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 20)
                
             
                
                if viewModel.isEditing {
                    TextField("Escribe un título", text: Binding(
                        get: { viewModel.note.title.isEmpty ? "" : viewModel.note.title },
                        set: { newValue in
                            viewModel.note.title = newValue.isEmpty ? "Sin título" : newValue
                        }
                    ))
                    .font(.system(size: 28, weight: .bold))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                } else {
                    Text(viewModel.note.title.isEmpty ? "Sin título" : viewModel.note.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(viewModel.note.title.isEmpty ? .gray : .primary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .onTapGesture { viewModel.isEditing = true }
                }
                
                Divider()
                
                // --- Cuerpo de la nota ---
                Group {
                    if viewModel.isEditing {
                        TextEditor(text: Binding(
                            get: { viewModel.note.content ?? "" },
                            set: { newValue in
                                if viewModel.isListMode,
                                   let lastChar = newValue.last,
                                   lastChar == "\n" {
                                    viewModel.note.content = newValue + "• "
                                } else {
                                    viewModel.note.content = newValue
                                }
                            }
                        ))
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            if let content = viewModel.note.content, !content.isEmpty {
                                Text(content) // 👈 ahora es texto plano
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true) // respeta saltos
                            } else {
                                Text("Escribe algo...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture { viewModel.isEditing = true }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isEditing {
                    Button("OK") {
                        if viewModel.note.title.isEmpty {
                            viewModel.note.title = "Sin título"
                        }
                        viewModel.saveNote()
                        viewModel.isEditing = false
                    }
                }
            }
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if viewModel.isEditing {
                    Button("• Lista") { viewModel.insertListMarker() }

                }
            }
        }
        .onAppear {
            viewModel.setContext(context)
        }
    }
}
