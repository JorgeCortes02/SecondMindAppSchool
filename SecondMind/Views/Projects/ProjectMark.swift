import SwiftUI
import SwiftData
import Foundation
import UIKit

struct ProjectMark: View {
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var modelView: ProjectMarkViewModel
    @State private var showAddProjectView: Bool = false
    @State private var isSyncing = false
    @State private var refreshID = UUID()
    
    init() {
        _modelView = StateObject(wrappedValue: ProjectMarkViewModel())
    }
    
    private let accentColor = Color.projectPurpel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 26) {
                        
                        // Cabecera visual coherente
                        headerCard(title: "Proyectos", accentColor: accentColor, sizeClass: sizeClass)
                            .padding(.top, 8)
                        
                        // Selector superior
                        PickerBar(options: ["Activos", "Finalizados"], selectedTab: $modelView.selectedTab)
                        
                        // Contenido principal
                        VStack(spacing: 18) {
                            if modelView.projectList.isEmpty {
                                emptyProjectList
                                    .frame(maxHeight: .infinity)
                            } else {
                                GeometryReader { scrollGeo in
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 0) {
                                            if sizeClass == .regular {
                                                // iPad: grid de 2 columnas
                                                LazyVGrid(columns: isPortrait ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 26) {
                                                    ForEach(modelView.projectList, id: \.self) { project in
                                                        NavigationLink(destination: ProjectDetall(editableProject: project)) {
                                                            projectCard(project: project, isCompactView: false)
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                }
                                                .padding(.horizontal, 20)
                                            } else {
                                                // iPhone: una sola tarjeta por fila
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
                                        .frame(minHeight: scrollGeo.size.height, alignment: .top)

                                  
                                        
                                    }.clipShape(RoundedRectangle(cornerRadius: 36))
                                        .padding(.bottom, 0)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.top, 10)
                    }
                    .padding(.top, 26)
                    .padding(.horizontal, 5)
                    .frame(maxWidth: 1200)
                    .background(
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color(red: 0.97, green: 0.96, blue: 1.0))
                            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                }
                .frame(maxHeight: .infinity)
                .padding(.bottom, sizeClass == .regular ?  geo.safeAreaInsets.bottom + 20 : geo.safeAreaInsets.bottom + 100)
                .id(refreshID)
                .refreshable {
                    await SyncManagerDownload.shared.syncAll(context: context)
                    modelView.loadProjects()
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    modelView.setContext(context, util: utilFunctions)
                    modelView.loadProjects()
                }
                .onChange(of: modelView.selectedTab) { _ in
                    withAnimation(.easeInOut) { modelView.loadProjects() }
                }
                .sheet(isPresented: $showAddProjectView, onDismiss: {
                    modelView.loadProjects()
                }) {
                    CreateProject()
                }
                
                // Botón flotante sobre el contenido
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        buttonControlMark
                    }
                }
                .ignoresSafeArea()
            }
        }
        
        
    }
    private var isPortrait: Bool {
        UIDevice.current.orientation.isPortrait
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
    
    // MARK: – Tarjeta de proyecto
    private func projectCard(project: Project, isCompactView: Bool) -> some View {
        VStack(spacing: 0) {
            
            // Cabecera del proyecto
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
            
            // Información del proyecto
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
                .font(sizeClass == .compact ? .system(size: 15) :.system(size: 17))
            }
            .padding(18)
            
            Spacer()
            
            // Botonera inferior
            HStack(spacing: 12) {
                NavigationLink(destination: ProjectTaskView(project: project)){
                    Text("Ver Tareas")
                } .buttonStyle(SoftButtonStyle(color: .taskButtonColor))
                
                
                   
                NavigationLink(destination: ProjectEventsView(project: project)){
                    Text("Ver Eventos")
                } .buttonStyle(SoftButtonStyle(color: .eventButtonColor))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 260,  maxHeight: sizeClass == .compact ? 290 : 300, alignment: .top)
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
   
    // MARK: – Empty List
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
