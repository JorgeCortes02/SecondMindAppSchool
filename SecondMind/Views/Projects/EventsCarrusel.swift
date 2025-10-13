import SwiftUI

struct EventCarrousel: View {
    @Bindable var editableProject: Project
    @EnvironmentObject var utilFunctions: generalFunctions
    @StateObject private var viewModel = EventCarrouselViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Título de la sección con contador y enlace
            HStack {
                Text("Eventos del proyecto")
                    .font(.headline)
                    .foregroundColor(Color.eventButtonColor)
                    .padding(.bottom, 4)
                
                Text("\(editableProject.events.filter { $0.status == .on }.count)")
                    .bold()
                    .padding(.bottom, 4)
                
                Spacer()
                
                NavigationLink(destination: ProjectEventsView(project: editableProject)) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.eventButtonColor)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.eventButtonColor)
                    }
                }
            }
            
            // Separador
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            // Contenido
            if viewModel.filteredEvents.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color.eventButtonColor.opacity(0.7))
                    
                    Text("No tienes eventos.")
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
                            ForEach(viewModel.filteredEvents.prefix(5), id: \.id) { event in
                                NavigationLink(destination: EventDetall(editableEvent: event)) {
                                    eventCard(for: event, width: cardWidth)
                                }
                            }
                        }
                        .padding(.horizontal, sideInset)
                    }
                    .frame(height: 120)
                }
                .frame(height: 140)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .onAppear {
            viewModel.loadEvents(for: editableProject)
        }
    }
    
    // MARK: - Event Card
    private func eventCard(for event: Event, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Rectangle()
                    .fill(Color.eventButtonColor)
                    .frame(width: 4)
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
                    } else {
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
                        Text(viewModel.formattedDate(event.endDate, using: utilFunctions))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.eventButtonColor)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 8)
                    .background(Color.eventButtonColor.opacity(0.1))
                    .clipShape(Capsule())
                }
                
                Spacer()
                
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(Color.eventButtonColor.opacity(0.85))
            }
        }
        .frame(width: width, height: 95)
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}
