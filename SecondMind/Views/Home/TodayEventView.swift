import SwiftUI
import SwiftData

struct TodayEventView: View {
  
    @EnvironmentObject var navModel: SelectedViewList
    @EnvironmentObject var utilFunctions: generalFunctions

    var todayEvent: [Event]
    private let accentColor = Color.eventButtonColor

    private var orderedEvents: [Event] {
        sortedArrayEvent(todayEvent).filter { Calendar.current.isDateInToday($0.endDate) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Título de la sección con flechita
            HStack {
                Text("Tus eventos de hoy")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    navModel.selectedTab = 0
                    navModel.selectedView = 2
                }) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentColor)
                }
            }

            Divider().padding(.bottom, 4)

            if orderedEvents.isEmpty {
                VStack(spacing: 18) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundColor(accentColor.opacity(0.75))

                    Text("No tienes eventos para hoy")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 140)
                .padding(.vertical, 16)

            } else {
                GeometryReader { geometry in
                    let cardWidth = geometry.size.width * 0.85
                    let sideInset = (geometry.size.width - cardWidth) / 2

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(orderedEvents.prefix(5).indices, id: \.self) { index in
                                let event = orderedEvents[index]
                                NavigationLink(destination: EventDetall(editableEvent: event)) {
                                    eventCard(event: event, cardWidth: cardWidth)
                                }
                                .buttonStyle(PlainButtonStyle()) // ✅ Evita comportamiento por defecto
                            }
                        }
                        .padding(.horizontal, sideInset)
                    }
                    .frame(height: 110)
                }
                .frame(height: 140)
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

    // MARK: - Vista tarjeta de evento individual
    // MARK: - Vista tarjeta de evento individual
    private func eventCard(event: Event, cardWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(event.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let description = event.descriptionEvent, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("Sin descripción")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    if let project = event.project?.title, !project.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text(project)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Label {
                        Text(utilFunctions.extractHour(event.endDate))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accentColor)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(accentColor.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(accentColor.opacity(0.85))
            }
        }
        .padding(16) // Más padding general
        .frame(width: cardWidth, height: 110) // Altura aumentada
        .modifier(EventCardModifier())
    
    }

    // MARK: - Funciones auxiliares

    private func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }
}
