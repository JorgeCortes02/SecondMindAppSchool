//
//  ProjectCardView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.
//
import SwiftUI

struct ProjectCardView: View {
    let project: Project
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.title)
                .font(.headline)
            if let date = project.endDate {
                Text("Próximo: \(date.formatted(.dateTime.day().month().year()))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("Tareas: \(project.tasks.count)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding().frame(minWidth: 300)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
