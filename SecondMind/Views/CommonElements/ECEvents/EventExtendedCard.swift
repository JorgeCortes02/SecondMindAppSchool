//
//  EventdExtendedCard.swift
//  SecondMind
//
//  Created by Jorge Cortés on 3/11/25.
//

// EventCardExpanded.swift

import SwiftUI
import SwiftData

struct EventCardExpanded: View {
    let event: Event
    let accentColor: Color
    @EnvironmentObject var utilFunctions: generalFunctions

    var body: some View {
        NavigationLink(destination: EventDetall(editableEvent: event)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)
                    
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    Spacer()
                }

                if let description = event.descriptionEvent,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("No hay descripción")
                        .font(.system(size: 14).italic())
                        .foregroundColor(.secondary.opacity(0.6))
                        .lineLimit(2)
                }

                if let project = event.project?.title,
                   !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Label(project, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.purple)
                } else {
                    Label("Sin proyecto", systemImage: "folder.badge.questionmark")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }

                Label(utilFunctions.extractHour(event.endDate), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(accentColor)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
