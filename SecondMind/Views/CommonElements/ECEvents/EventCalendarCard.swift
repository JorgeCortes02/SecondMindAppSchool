import SwiftUI

struct EventCalendarCard<VM: BaseEventViewModel>: View {
    @ObservedObject var modelView: VM
    @Binding var selectedDate: Date
    let accentColor: Color
    @Binding var showCal: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona fecha")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(.horizontal, 20)
            .onChange(of: selectedDate) { newDate in
                withAnimation(.easeInOut(duration: 0.3)) {
                    modelView.loadEvents(date: newDate)
                    showCal = false // Cierra el calendario
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
