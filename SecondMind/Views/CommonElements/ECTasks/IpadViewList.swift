import SwiftUI

// Esta vista genérica funciona con cualquier ViewModel que adopte BaseTaskViewModel.
struct TasksSectionsiPadView<ViewModel: BaseTaskViewModel>: View {
    
    @ObservedObject var modelView: ViewModel
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 24) {
            if modelView.selectedTab == 0 {
                // Pestaña "Activas": Sin fecha y Agendadas
                sectionView(title: "Sin fecha") {
                    let noDateTasks = modelView.listTask.filter { $0.endDate == nil && $0.status == .on }
                    taskGrid(tasks: noDateTasks)
                }
                sectionView(title: "Agendadas") {
                    // Filtra las tareas por la fecha seleccionada
                    let datedTasks = modelView.listTask.filter {
                        if let due = $0.endDate {
                            return Calendar.current.isDate(due, inSameDayAs: modelView.selectedData) && $0.status == .on
                        }
                        return false
                    }
                    VStack(spacing: 12) {
                        // Selector de fecha
                        HStack {
                            Spacer()
                            DatePicker(
                                "",
                                selection: $modelView.selectedData,
                                in: Date()...,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .shadow(color: .black.opacity(0.08), radius: 6)
                            Spacer()
                        }
                        // Grid de tareas agendadas
                        taskGrid(tasks: datedTasks)
                    }
                }
            } else {
                // Pestaña "Finalizadas"
                sectionView(title: "Finalizadas") {
                    let completedTasks = modelView.listTask.filter { $0.status == .off }
                    taskGrid(tasks: completedTasks)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: – Sección genérica con título, conteo y contenido
    private func sectionView(title: String, @ViewBuilder content: @escaping () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(taskCount(for: title))")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            content()
        }
        .frame(maxWidth: 800)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8)
        .padding(.horizontal)
    }
    
    // MARK: – Grid de tareas
    @ViewBuilder
    private func taskGrid(tasks: [TaskItem]) -> some View {
        if tasks.isEmpty {
            // Estado vacío
            EmptyList(color: accentColor, textIcon: "tray")
        } else {
            // Dos columnas
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(tasks, id: \.id) { task in
                    // Pasa el binding de listTask para poder modificarlo desde las tarjetas
                    TaskCardExpanded(
                        task: task,
                        accentColor: accentColor,
                        listTask: $modelView.listTask
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }
    
    // MARK: – Conteo de tareas por sección
    private func taskCount(for title: String) -> Int {
        switch title {
        case "Sin fecha":
            return modelView.listTask.filter { $0.endDate == nil && $0.status == .on }.count
        case "Agendadas":
            return modelView.listTask.filter {
                if let due = $0.endDate {
                    return Calendar.current.isDate(due, inSameDayAs: modelView.selectedData) && $0.status == .on
                }
                return false
            }.count
        case "Finalizadas":
            return modelView.listTask.filter { $0.status == .off }.count
        default:
            return 0
        }
    }
}
