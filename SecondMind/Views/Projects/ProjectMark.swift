import SwiftUI
import SwiftData
import Foundation
import UIKit

struct ProjectMark: View {
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @StateObject private var modelView: ProjectMarkViewModel
    @State private var showAddProjectView: Bool = false
    @State private var isSyncing = false
    @State private var refreshID = UUID()
    
    init() {
        _modelView = StateObject(wrappedValue: ProjectMarkViewModel())
    }
    
    private let accentColor = Color.projectPurpel
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerCard(title: "Proyectos")
                    .padding(.top, 16)
                
                PickerBar(options: ["Activos", "Finalizados"], selectedTab: $modelView.selectedTab)
                
                ScrollView {
                    VStack(spacing: 26) { // 💡 más espacio entre bloques
                        if sizeClass == .regular {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(modelView.selectedTab == 0 ? "Activos" : "Finalizados")
                                        .foregroundColor(.primary)
                                        .font(.title2.weight(.bold))
                                    Spacer()
                                    Text("\(modelView.projectList.count)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                
                                Rectangle()
                                    .fill(Color.primary.opacity(0.1))
                                    .frame(height: 1)
                                
                                if modelView.projectList.isEmpty {
                                    emptyProjectList
                                } else {
                                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 26) { // 💡 más espacio entre tarjetas
                                        ForEach(modelView.projectList, id: \.self) { project in
                                            NavigationLink(destination: ProjectDetall(editableProject: project)) {
                                                projectCard(project: project)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                }
                            }
                            .frame(maxWidth: 800)
                            .background(Color.cardBG)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        } else {
                            if modelView.projectList.isEmpty {
                                emptyProjectList
                            } else {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 36) { // 💡 iPhone también un poco más
                                    ForEach(modelView.projectList, id: \.self) { project in
                                        NavigationLink(destination: ProjectDetall(editableProject: project)) {
                                            projectCard(project: project)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
                .refreshable {
                    await SyncManagerDownload.shared.syncProjects(context: context)
                    modelView.loadProjects()
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    buttonControlMark
                }
               
            }
            .onAppear {
                modelView.setContext(context, util: utilFunctions)
                modelView.loadProjects()
            }
            .onChange(of: modelView.selectedTab) { _ in
                withAnimation(.easeInOut) { modelView.loadProjects() }
            }
            .ignoresSafeArea(.keyboard)
        }
        .sheet(isPresented: $showAddProjectView, onDismiss: {
            modelView.loadProjects()
        }) {
            CreateProject()
        }
    }
    
   
    // MARK: – Botonera inferior (iPad: 🔄 + ➕ | iPhone: solo ➕)
    private var buttonControlMark: some View {
        
        
        glassButtonBar(funcAddButton: {showAddProjectView = true},
                       funcSyncButton: {
            Task {
                isSyncing = true
                await SyncManagerDownload.shared.syncProjects(context: context)
                withAnimation(.easeOut(duration: 0.3)) {
                    refreshID = UUID()
                    isSyncing = false
                }
            }},
                       funcCalendarButton: {},
                       color: accentColor,
                       selectedTab: $modelView.selectedTab,
                       isSyncing: $isSyncing)
                
    }
    // MARK: Card
    private func projectCard(project: Project) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "folder")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                Text(project.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.taskButtonColor)
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 228/255, green: 214/255, blue: 244/255))
            .cornerRadius(16, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 10) {
                Label("Próximo evento:", systemImage: "calendar.badge.clock")
                    .foregroundStyle(Color.black)
                Text(modelView.nextEventText(events: project.events))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Label("\(project.events.filter { $0.status == .on }.count) eventos activos", systemImage: "calendar")
                    .foregroundStyle(Color.eventButtonColor)
                
                Label("\(project.tasks.filter { $0.status == .on }.count) tareas activas", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.taskButtonColor)
            }
            .padding()
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple, lineWidth: 0.5)
        )
    }
    
    private var emptyProjectList: some View {
        
        EmptyList(color: accentColor, textIcon: "folder")
        
    }
}

// MARK: Rounded corners
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
