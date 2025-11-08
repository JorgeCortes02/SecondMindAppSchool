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
                    VStack(spacing: 26) {
                        
                        if modelView.projectList.isEmpty {
                            emptyProjectList
                        } else {
                            
                            if sizeClass == .regular {
                                // ✅ iPad: grid de 2 columnas
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 26) {
                                    ForEach(modelView.projectList, id: \.self) { project in
                                        NavigationLink(destination: ProjectDetall(editableProject: project)) {
                                            projectCard(project: project, isCompactView: false)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                                .frame(maxWidth: 800)
                                .background(Color.cardBG)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                                
                            } else {
                                // ✅ iPhone: una sola tarjeta por fila
                                VStack(spacing: 10) {
                                    ForEach(modelView.projectList, id: \.self) { project in
                                        NavigationLink(destination: ProjectDetall(editableProject: project)) {
                                            projectCard(project: project, isCompactView: true)
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
                    await SyncManagerDownload.shared.syncAll(context: context)
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
    
    // MARK: – Botonera inferior
    private var buttonControlMark: some View {
        glassButtonBar(
            funcAddButton: { showAddProjectView = true },
            funcSyncButton: {
                Task {
                    isSyncing = true
                    await SyncManagerDownload.shared.syncProjects(context: context)
                    withAnimation(.easeOut(duration: 0.3)) {
                        refreshID = UUID()
                        isSyncing = false
                    }
                }
            },
            funcCalendarButton: {},
            color: accentColor,
            selectedTab: $modelView.selectedTab,
            isSyncing: $isSyncing
        )
    }
    
    private func projectCard(project: Project, isCompactView: Bool) -> some View {
   
            
            
            VStack(spacing: 0) {
                
                // 📁 Cabecera del proyecto sin color de fondo (más minimalista)
                HStack(spacing: 10) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.projectPurpel)
                    Text(project.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.taskButtonColor)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                
                Divider()
                
                // 📅 Información del proyecto
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Próximo evento")
                            .font(.headline)
                            .foregroundColor(.taskButtonColor)
                        
                        Text(modelView.nextEventText(events: project.events))
                            .font(.subheadline)
                            .foregroundColor(Color.eventButtonColor.opacity(0.75))
                    }
                    Divider().padding(.vertical, 6)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.taskButtonColor)
                            Text("\(project.tasks.filter { $0.status == .on }.count) tareas activas")
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color.eventButtonColor)
                            Text("\(project.events.filter { $0.status == .on }.count) eventos activos")
                        }
                    }
                    .font(.system(size: 15))
                }
                .padding(18)
                
                Spacer()
                
                // 🔘 Botonera inferior más discreta
                HStack(spacing: 12) {
                    Button("Ver Tareas") {}
                        .buttonStyle(SoftButtonStyle(color: .taskButtonColor))
                    Button("Ver Eventos") {}
                        .buttonStyle(SoftButtonStyle(color: .eventButtonColor))
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity, minHeight: 260, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 0.75)
            )
        
        .padding(.vertical, 8)
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
