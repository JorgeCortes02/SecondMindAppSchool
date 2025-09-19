//
//  ProjectMark.swift
//  SecondMind
//
//  Created by Jorge Cortés on 20/6/25.
//

import SwiftUI
import SwiftData
import Foundation
import UIKit

struct ProjectMark: View {
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) var sizeClass   // 👈 clave

    @State private var readyToShowTasks: Bool = false
    @State private var showAddProjectView: Bool = false
    @State private var selectedTab: Int = 0
    @State private var projectList: [Project] = []

    private let accentColor = Color(red: 160/255, green: 130/255, blue: 180/255)

    var body: some View {
        VStack(spacing: 20) {
            headerCard(title: "Proyectos")
                .padding(.top, 16)

            pickerBard

            ScrollView {
                VStack(spacing: 20) {
                    if projectList.isEmpty {
                        emptyProjectList
                    } else {
                        showProjectList
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: sizeClass == .regular ? 800 : .infinity) // 👈 iPad ancho máx. 800
                .frame(maxWidth: .infinity) // centra
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                buttonControlMark
            }
            .padding(.trailing, 16)
            .padding(.bottom, 80)
        }
        .sheet(isPresented: $showAddProjectView, onDismiss: {
            
            
            reloadProjects()
            
            withAnimation(.easeInOut(duration: 0.2)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        readyToShowTasks = true
                    }
                }
            }
        }) {
            CreateProject()
        }
        .onAppear {
            reloadProjects()
        }
        .onChange(of: selectedTab) { _ in
            reloadProjects()
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: – Mostrar lista proyectos
    private var showProjectList: some View {
        let columns: [GridItem] = {
            if sizeClass == .regular {
                // iPad: 3 columnas
                return Array(repeating: GridItem(.flexible()), count: 3)
            } else {
                // iPhone: 2 columnas
                return Array(repeating: GridItem(.flexible()), count: 2)
            }
        }()

        return LazyVGrid(columns: columns, spacing: 30) {
            ForEach(projectList, id: \.self) { project in
                NavigationLink(destination: ProjectDetall(editableProject: project)) {
                    projectElement(project: project)
                }
            }
        }
        .padding()
    }

    // MARK: – Recarga proyectos
    private func reloadProjects() {
        if selectedTab == 1 {
            projectList = HomeApi.downloadOffProjects(context: context)
        } else {
            projectList = HomeApi.downloadOnProjects(context: context)
        }
    }

    // MARK: – Segment Button
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) { selectedTab = tag }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .taskButtonColor)
                .frame(maxHeight: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.taskButtonColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: – Picker Bar
    private var pickerBard: some View {
        HStack(spacing: 10) {
            segmentButton(title: "Activos", tag: 0)
            segmentButton(title: "Finalizados", tag: 1)
        }
        .padding(15)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }

    // MARK: – Botón flotante
    private var buttonControlMark: some View {
        Button(action: { showAddProjectView = true }) {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(14)
                .background(Circle().fill(Color.taskButtonColor))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        }
    }

    // MARK: – Lista vacía
    private var emptyProjectList: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 90)
                .foregroundColor(accentColor.opacity(0.7))

            Text("No hay proyectos disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }

    // MARK: – Elemento proyecto
    private func projectElement(project: Project) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                    .padding(.bottom, 4)

                Text(project.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                    .padding(.bottom, 4)
                    .lineLimit(1)
            }
            .padding()
            .padding(.bottom, 0)
            .frame(maxWidth: .infinity)
            .background(Color(red: 228/255, green: 214/255, blue: 244/255))
            .cornerRadius(16, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 10) {
                Label("Próximo evento: ", systemImage: "calendar.badge.clock")
                    .foregroundStyle(Color.black)

                Text("\(firtsEvent(events: project.events))")
                    .frame(maxWidth: .infinity, alignment: .center)

                Label("\(project.events.filter { $0.status == .on }.count) eventos activos",
                      systemImage: "calendar")
                    .foregroundStyle(Color.eventButtonColor)
                Label("\(project.tasks.filter { $0.status == .on }.count) tareas activas",
                      systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.taskButtonColor)
            }
            .padding()
            .padding(.top, 0)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(red: 242/255, green: 242/255, blue: 242/255), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 0.5)
        )
    }

    private func firtsEvent(events: [Event]) -> String {
        let today = Date()
        let futureEvents = events.filter { $0.endDate > today }
        let firtsEvent = futureEvents.min(by: { $0.endDate < $1.endDate })
        if let date = firtsEvent?.endDate {
            return utilFunctions.formattedDateAndHour(date)
        }
        return "No hay eventos"
    }
}

// MARK: – RoundedCorner Extension
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
