import SwiftUI
import SwiftData

struct CreateProject: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject private var viewModel = CreateProjectViewModel()

    // 🎨 Estética coherente con CreateTask / CreateEvent
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke   = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.2)
    private let fieldBG      = Color(red: 248/255, green: 248/255, blue: 250/255)
    private let softRed      = Color(red: 220/255, green: 75/255, blue: 75/255)

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.96, blue: 1.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // 🧾 Contenedor visual principal
                    VStack(spacing: 26) {

                        // Encabezado igual que en CreateTask
                        headerCard

                        Divider().padding(.horizontal, 20)

                        // ——— Título ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Escribe el título", text: $viewModel.newProject.title)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(fieldBG)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        if viewModel.isIncompleteTitle {
                            Text("⚠️ Es obligatorio añadir un título")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }

                        Divider().padding(.horizontal, 20)

                        // ——— Fecha límite ———
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fecha fin")
                                .font(.headline)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 12) {
                                DatePicker(
                                    "Selecciona una fecha",
                                    selection: Binding(
                                        get: { viewModel.newProject.endDate ?? Date() },
                                        set: { viewModel.newProject.endDate = $0 }
                                    ),
                                    in: Date()...,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)

                                if viewModel.newProject.endDate != nil {
                                    Button("Eliminar fecha") {
                                        viewModel.clearDate()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(fieldBG)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Descripción ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextEditor(
                                text: Binding(
                                    get: { viewModel.newProject.descriptionProject ?? "" },
                                    set: { viewModel.newProject.descriptionProject = $0 }
                                )
                            )
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(fieldBG)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // ——— Botones ———
                        VStack(spacing: 14) {
                            Button(action: { viewModel.saveProject(dismiss: dismiss) }) {
                                Text("Guardar Proyecto")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.taskButtonColor, purpleAccent],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                        .cornerRadius(12)
                                    )
                            }

                            Button(action: { dismiss() }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).fill(softRed))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 22)
                    .frame(maxWidth: 800)
                    .padding(.top, 16)
                }
                .backgroundStyle(Color(red: 0.97, green: 0.96, blue: 1.0))
            }
        }
        .onAppear {
            viewModel.setContext(context: context, util: utilFunctions)
        }
    }

    // 🟥 Cabecera visual adaptada a la nueva estética
    private var headerCard: some View {
        HStack {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.taskButtonColor)
            Text("Crear proyecto")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.taskButtonColor)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }
}
