import SwiftUI
import SwiftData
import Foundation
// MARK: - Colores personalizados (extiende según estilo general)
extension Color {
    static let taskAccent     = Color(red: 8/255, green: 56/255, blue: 97/255)
    static let cardBackground = Color.white
}
    
    // MARK: - Modificador reutilizable para tarjetas de tarea
    struct TaskCardModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
    }
    
    struct TodayTaskView: View {
        
        @Environment(\.modelContext) private var context
        
        @Binding  var todayTask: [TaskItem]
        
        
        @EnvironmentObject var  navModel : SelectedViewList
        
        
        // Color de acento (igual que en TodayElementsView)
        private let accentColor = Color.taskAccent
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                
                // Título de la sección con "Ver más" y flechita
                HStack {
                    Text("Tus tareas de hoy")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        navModel.selectedTab = 1
                        navModel.selectedView = 1
                    }) {
                        HStack(spacing: 4) {
                            Text("Ver más")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(accentColor)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                    }
                }
                
                // Separador sutil
                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 1)
                
                // Contenido según número de tareas pendientes
                if todayTask.isEmpty {
                    // 1. No hay tareas
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "checkmark.seal.text.page")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 90)
                            .foregroundColor(accentColor.opacity(0.7))
                        
                        Text("No hay tareas disponibles para hoy")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding(20)
                    
                } else if todayTask.count == 1 {
                    // 2. Una sola tarea pendiente
                    NavigationLink(destination: TaskDetall(editableTask: todayTask[0])) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checklist")
                                .font(.system(size: 22))
                                .foregroundColor(accentColor)
                            
                            Text(todayTask[0].title)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                todayTask[0].completeDate = Date()
                                todayTask[0].status = .off
                                do {
                                    try context.save()
                                    
                                    withAnimation {
                                        todayTask.removeAll { $0.id == todayTask[0].id }
                                    }
                                    
                                } catch {
                                    print("❌ Error al guardar: \(error)")
                                }
                            }) {
                                Image(systemName: "circle")
                                    .font(.system(size: 21))
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding(12)
                        .modifier(TaskCardModifier())}
                    
                } else {
                    // 3. Más de una tarea pendiente: muestro las dos primeras
                    ForEach(0..<min(todayTask.count, 2), id: \.self) { index in
                        NavigationLink(destination: TaskDetall(editableTask: todayTask[index])) {
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 22))
                                    .foregroundColor(accentColor)
                                
                                Text(todayTask[index].title)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    todayTask[index].completeDate = Date()
                                    todayTask[index].status = .off
                                    do {
                                        try context.save()
                                        
                                        withAnimation {
                                            todayTask.removeAll { $0.id == todayTask[index].id }
                                        }
                                        
                                    } catch {
                                        print("❌ Error al guardar: \(error)")
                                    }
                                }) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 21))
                                        .foregroundColor(Color.gray)
                                }
                            }
                            .padding(12)
                            .modifier(TaskCardModifier())}
                    }
                }
            }
            .padding(20)
            .background(Color.cardBackground)
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 40)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .onAppear{
                
                
                
            }
        }
        
        // Ordena el array por dueDate
        private func sortedArrayTask(_ inputArray: [TaskItem]) -> [TaskItem] {
            inputArray.sorted { p1, p2 in
                switch (p1.endDate, p2.endDate) {
                case let (d1?, d2?): return d1 < d2
                case (nil, _?): return false   // nil va después
                case (_?, nil): return true
                case (nil, nil): return false
                }
            }
        }
        
        
        
        
    }

