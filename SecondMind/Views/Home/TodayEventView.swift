import SwiftUI
import SwiftData
// MARK: - Colores personalizados (extiende según estilo general)



struct TodayEventView: View {
  
    @EnvironmentObject var  navModel : SelectedViewList
    @EnvironmentObject var  utilFunctions : generalFunctions

    var todayEvent: [Event]
    private let accentColor = Color.eventButtonColor

    private var orderedEvents: [Event] {
        sortedArrayEvent(todayEvent).filter { Calendar.current.isDateInToday($0.endDate) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Título de la sección con flechita
            HStack {
                Text("Tus eventos de hoy")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {
                    navModel.selectedTab = 0
                    navModel.selectedView = 2
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

            // Contenido según si hay eventos
            if orderedEvents.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(accentColor.opacity(0.7))

                    Text("No tienes eventos para hoy")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(20)

            } else {
                GeometryReader { geometry in
                    let cardWidth = geometry.size.width * 0.85
                    let sideInset = (geometry.size.width - cardWidth) / 2

                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        
                        
                        HStack(spacing: 16) {
                            ForEach(orderedEvents.prefix(5).indices, id: \.self) { index in
                                
                           
                                
                                NavigationLink(destination: EventDetall(editableEvent: orderedEvents[index])){
                                    
                                    let event = orderedEvents[index]

                                    VStack(alignment: .leading, spacing: 12) {
                                                HStack(alignment: .center, spacing: 12) {
                                                    Rectangle()
                                                        .fill(accentColor)
                                                        .frame(width: 4)
                                                        .frame(maxHeight: .infinity)
                                                        .cornerRadius(2)

                                                    VStack(alignment: .leading, spacing: 6) {
                                                        Text(event.title)
                                                            .font(.system(size: 18, weight: .semibold))
                                                            .foregroundColor(.primary)
                                                            .lineLimit(2)

                                                        if let description = event.descriptionEvent, !description.isEmpty {
                                                            Text(description)
                                                                .font(.system(size: 14))
                                                                .foregroundColor(.secondary)
                                                                .lineLimit(2)
                                                        }else{
                                                            Text("No hay descripción")
                                                                .font(.system(size: 14))
                                                                .foregroundColor(.secondary)
                                                                .lineLimit(2)
                                                            
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
                                                            .padding(.vertical, 2)
                                                            .padding(.horizontal, 8)
                                                            .background(accentColor.opacity(0.1))
                                                            .clipShape(Capsule())
                                                        }
                                                    

                                                    Spacer()

                                                    Image(systemName: "calendar.circle.fill")
                                                        .font(.system(size: 34))
                                                        .foregroundColor(accentColor.opacity(0.85))
                                                }
                                            }
                                    .padding(12)
                                    .frame(width: cardWidth, height: 95)
                                    .modifier(EventCardModifier())
                                }
                                
                                
                            }
                        }
                        .padding(.horizontal, sideInset)
                    }
                    .frame(height: 120)
                }
                .frame(height: 140) // Asegura que GeometryReader tenga altura adecuada
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBG)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Funciones auxiliares

    private func sortedArrayEvent(_ inputArray: [Event]) -> [Event] {
        inputArray.sorted { $0.endDate < $1.endDate }
    }


    
}

