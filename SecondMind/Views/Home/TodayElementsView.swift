import SwiftUI
import SwiftData

// MARK: - Colores personalizados (puedes mover esto a Theme.swift)
extension Color {
    static let cardBG            = Color(red: 0.985, green: 0.985, blue: 0.985) // #FBFBFB
    static let taskButtonColor   = Color(red: 8/255, green: 56/255, blue: 97/255)
    static let eventButtonColor  = Color(red: 0.95, green: 0.42, blue: 0.25)     // #F26B40
    static let primaryText       = Color(red: 0.122, green: 0.180, blue: 0.271) // #1F2E45
    static let secondaryText     = Color(red: 0.627, green: 0.659, blue: 0.714) // #A0A8B6
}

// MARK: - Estilo de botón redondeado reutilizable
struct RoundedButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(18)
            .shadow(color: backgroundColor.opacity(0.25), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct TodayElementsView: View {
    

    
    @Binding var todayTask: [TaskItem]
    @Binding var todayEvent: [Event]
    
    @State private var showAddTaskView: Bool = false
    @State private var showAddEventView: Bool = false
    @Environment(\.modelContext) private var context
    
    private var todayTaskCount: Int  { todayTask.count }
    private var todayEventCount: Int { todayEvent.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
         
            
            Text("Veamos tu día:")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            
            // Contadores de tareas y eventos
            HStack(spacing: 24) {
                Label {
                    Text("Tareas: \(todayTaskCount)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primaryText)
                } icon: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.taskButtonColor)
                }
                
                Label {
                    Text("Eventos: \(todayEventCount)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primaryText)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(.eventButtonColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Botones de nueva tarea y nuevo evento usando RoundedButtonStyle
            HStack(spacing: 16) {
                Button(action: {
                    showAddTaskView = true
                }) {
                    Label("Nueva Tarea", systemImage: "checkmark.circle")
                }.sheet(isPresented: $showAddTaskView, onDismiss: {
                    todayTask = HomeApi.fetchTodayTasks(context: context)
                    showAddTaskView = false
                }){
                    CreateTask()
                }
                .buttonStyle(RoundedButtonStyle(backgroundColor: .taskButtonColor))
                
                Button(action: {
                    showAddEventView = true
                }) {
                    Label("Nuevo Evento", systemImage: "calendar.badge.plus")
                }.sheet(isPresented: $showAddEventView, onDismiss: {
                    todayEvent = HomeApi.fetchTodayEvents(context: context)
                    showAddEventView = false
                }){
                    CreateEvent()
                }
                .buttonStyle(RoundedButtonStyle(backgroundColor: .eventButtonColor))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Button(action: {
                showAddTaskView = true
            }) {
                Label("Nuevo Proyecto", systemImage: "checkmark.circle")
            }.sheet(isPresented: $showAddTaskView, onDismiss: {
                
            }){
                CreateProject()
            }
            .buttonStyle(RoundedButtonStyle(backgroundColor: Color.purple))
        }
        .padding(20)
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBG)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
