import SwiftUI
import SwiftData


// MARK: - Estilo de botón redondeado reutilizable
struct RoundedButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity) // ocupa todo el ancho
            .background(backgroundColor)
            .cornerRadius(18)
            .shadow(color: backgroundColor.opacity(0.25), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


import SwiftUI
import SwiftData

struct TodayElementsView: View {
    @Binding var todayTask: [TaskItem]
    @Binding var todayEvent: [Event]
    
    @State private var showAddTaskView: Bool = false
    @State private var showAddEventView: Bool = false
    @State private var showAddProjectView: Bool = false
 
    @Environment(\.modelContext) private var context
    
    private var todayTaskCount: Int  { todayTask.count }
    private var todayEventCount: Int { todayEvent.count }
    let utilFunctions = generalFunctions()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // 🔖 Encabezado ligero
            Text("Veamos tu día:")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.primary)
            
            // 📅 Fecha destacada pero más compacta
            Text(utilFunctions.formattedDate(Date()))
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(.taskButtonColor)
                .padding(.bottom, 6)
            
            Divider()
            
            // ✅ Contadores estilizados con iconos más pequeños
            HStack(spacing: 28) {
                statBadge(title: "Tareas", value: todayTaskCount, icon: "checkmark.circle.fill", color: .taskButtonColor)
                statBadge(title: "Eventos", value: todayEventCount, icon: "calendar", color: .eventButtonColor)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.cardBG)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 16).frame(maxWidth: 800)
    }
    
    // 🛠️ Contador compacto visual
    @ViewBuilder
    private func statBadge(title: String, value: Int, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20)) // 🔍 Icono más pequeño
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                Text(title)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}
