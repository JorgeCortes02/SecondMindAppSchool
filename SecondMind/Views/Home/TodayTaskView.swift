import SwiftUI
import SwiftData
import Foundation

struct TodayTaskView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var navModel: SelectedViewList
    
    @Binding var todayTask: [TaskItem]
    
    private let accentColor = Color.taskButtonColor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 🔖 Título + "Ver más"
            HStack {
                Text("Tus tareas de hoy")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    navModel.selectedTab = 1
                    navModel.selectedView = 1
                }) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentColor)
                }
            }
            
            Divider()

            // 📝 Contenido según número de tareas
            if todayTask.isEmpty {
                VStack(spacing: 18) {
                    Image(systemName: "checkmark.seal.text.page")
                        .font(.system(size: 48))
                        .foregroundColor(accentColor.opacity(0.75))
                    
                    Text("No hay tareas disponibles para hoy")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.vertical, 12)
                
            } else if todayTask.count == 1 {
                taskCard(task: todayTask[0])
            } else {
                ForEach(0..<min(todayTask.count, 2), id: \.self) { index in
                    taskCard(task: todayTask[index])
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.cardBG)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    // MARK: - Tarjeta de una tarea individual
    private func taskCard(task: TaskItem) -> some View {
        NavigationLink(destination: TaskDetall(editableTask: task)) {
            HStack(spacing: 12) {
                Image(systemName: "checklist")
                    .font(.system(size: 20))
                    .foregroundColor(accentColor)
                
                Text(task.title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: {
                    markTaskAsDone(task)
                }) {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle()) // ✅ evita el resaltado azul
    }
    
    // MARK: - Lógica para completar tarea
    private func markTaskAsDone(_ task: TaskItem) {
        task.completeDate = Date()
        task.status = .off
        do {
            try context.save()
            Task {
                await SyncManagerUpload.shared.uploadTask(task: task)
            }
            withAnimation {
                todayTask.removeAll { $0.id == task.id }
            }
        } catch {
            print("❌ Error al guardar: \(error)")
        }
    }
}
