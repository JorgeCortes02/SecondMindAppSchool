import SwiftUI
import SwiftData

struct EventListItem: View {
    let event: Event
    let accentColor: Color
    
    @EnvironmentObject var utilFunctions: generalFunctions
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 20))
                .foregroundColor(accentColor)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Label {
                        Text(utilFunctions.extractHour(event.endDate))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(accentColor)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(accentColor.opacity(0.12))
                    .clipShape(Capsule())
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
                    HStack(spacing: 6) {
                        Image(systemName: "folder")
                            .font(.system(size: 13))
                            .foregroundColor(.purple)

                        Text(project)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.purple)
                            .lineLimit(1)
                    }
                    .padding(.top, 4)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.badge.questionmark")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.6))

                        Text("Sin proyecto")
                            .font(.system(size: 13))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
    }
}
