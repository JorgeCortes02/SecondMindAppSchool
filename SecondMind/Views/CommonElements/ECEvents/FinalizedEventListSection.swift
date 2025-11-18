import SwiftUI

struct FinalizedEventListSection<VM: BaseEventViewModel>: View {
    @ObservedObject var modelView: VM
    let accentColor: Color
    let isIpad: Bool
    
    @EnvironmentObject var utilFunctions: generalFunctions
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // ---- Header ----
                    HStack {
                        Text("Finalizados")
                            .foregroundColor(.eventButtonColor)
                            .font(.title2.weight(.bold))
                        Spacer()
                        Text("\(modelView.events.count)")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 1)
                    
                    // ---- Cuerpo de eventos agrupados por fecha ----
                    if modelView.events.isEmpty {
                        EmptyList(color: accentColor, textIcon: "calendar.badge.exclamationmark")
                            .frame(maxHeight: .infinity)
                            .padding(.top, 12)
                            
                    } else {
                        let grouped = Dictionary(grouping: modelView.events) {
                            Calendar.current.startOfDay(for: $0.endDate)
                        }
                        
                        let sortedGroups = grouped
                            .map { (date: $0.key, events: $0.value.sorted { $0.endDate > $1.endDate }) }
                            .sorted { $0.date > $1.date }
                        
                        VStack(spacing: 24) {
                            ForEach(sortedGroups, id: \.date) { group in
                                VStack(alignment: .leading, spacing: 18) {
                                    
                                    // ---- Fecha ----
                                    Text(utilFunctions.formattedDate(group.date))
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    // ---- Eventos Listados ----
                                    if isIpad {
                                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                            ForEach(group.events, id: \.id) { event in
                                                EventCardExpanded(event: event, accentColor: accentColor)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    } else {
                                        LazyVStack(spacing: 12) {
                                            ForEach(group.events, id: \.id) { event in
                                                NavigationLink(destination: EventDetall(editableEvent: event)) {
                                                    EventListItem(event: event, accentColor: accentColor)
                                                }
                                            }
                                        }
                                       
                                    }
                                }
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 60)
                    }
                }
                .frame(minHeight: geometry.size.height , alignment: .top)
               
                .padding(.horizontal, 16)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            } .clipShape(RoundedRectangle(cornerRadius: 36))
        }
    }
}
