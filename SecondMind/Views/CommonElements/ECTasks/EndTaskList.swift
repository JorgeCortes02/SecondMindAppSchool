import SwiftUI

struct EndTaskList<ViewModel: BaseTaskViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    let utilFunctions = generalFunctions()
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(groupTasksByDate(), id: \.date) { group in
                VStack(alignment: .leading, spacing: 8) {
                    // Encabezado de la fecha
                    Text(utilFunctions.formattedDate(group.date))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    Color.taskButtonColor.opacity(0.8)
                                )
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Tareas de esa fecha
                    VStack{
                        ForEach(group.tasks, id: \.id) { task in
                            taskRow(task)
                        }
                    }.padding(.top, 10)
                }
                .padding(.vertical)
            }
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Agrupar tareas por fecha
    private func groupTasksByDate() -> [(date: Date, tasks: [TaskItem])] {
        let tasksWithDate = viewModel.listTask.filter { $0.completeDate != nil }
        let groupedDict = Dictionary(grouping: tasksWithDate) { task in
            Calendar.current.startOfDay(for: task.completeDate!)
        }
        return groupedDict.map { (date: $0.key, tasks: $0.value) }
                          .sorted { $0.date > $1.date }
    }
    
    // MARK: - Vista de fila de tarea con animaciones
    private func taskRow(_ task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let due = task.endDate {
                    Text(utilFunctions.formattedDateShort(due))
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            
            Spacer()
            
            Button {
                viewModel.deleteTask(task)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
