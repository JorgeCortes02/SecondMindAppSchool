import SwiftUI

struct FinalizedEventListSection<VM: BaseEventViewModel>: View {
    @ObservedObject var modelView: VM
    let accentColor: Color
    let isIpad: Bool

    @EnvironmentObject var utilFunctions: generalFunctions

    var body: some View {
        let grouped = Dictionary(grouping: modelView.events) {
            Calendar.current.startOfDay(for: $0.endDate)
        }

        let sortedGroups = grouped
            .map { (date: $0.key, events: $0.value.sorted { $0.endDate > $1.endDate }) }
            .sorted { $0.date > $1.date }

        return VStack {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(sortedGroups, id: \.date) { group in
                    VStack(alignment: .center, spacing: 18) {

                        // ---- FECHA CENTRADA ----
                        Text(utilFunctions.formattedDate(group.date))
                            .font(.title3.weight(.bold))
                            .foregroundColor(.primary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.85, blue: 0.75),
                                                Color(red: 1.0, green: 0.78, blue: 0.65)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                            .frame(maxWidth: .infinity, alignment: .center)

                        // ---- EVENTOS ----
                        if isIpad {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(group.events, id: \.id) { event in
                                    EventCardExpanded(event: event, accentColor: accentColor)
                                }
                            }
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
                    .padding(.horizontal, isIpad ? 20 : 16)
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: isIpad ? 800 : .infinity)
            .background(Color.cardBG)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
        .padding(.bottom, 30)
    }
}
