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
    
    private let accentColor = Color.purple
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerCard(title: "Proyectos")
                    .padding(.top, 16)
                
                if sizeClass == .regular {
                    HStack(spacing: 10) {
                        segmentButton(title: "Activos", tag: 0)
                        segmentButton(title: "Finalizados", tag: 1)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.cardBackground)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    )
                    .frame(maxWidth: 360)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    pickerBar
                }
                
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
                            .background(Color.cardBackground)
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
    
    // MARK: Picker
    private var pickerBar: some View {
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
    
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (modelView.selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) { modelView.selectedTab = tag }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .blue)
                .frame(maxHeight: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
    // MARK: – Botonera inferior (iPad: 🔄 + ➕ | iPhone: solo ➕)
    private var buttonControlMark: some View {
        HStack(spacing: 14) {
            Spacer()

            // 💻 iPad (regular width)
            if sizeClass == .regular {
                if #available(iOS 26.0, *) {
                    // 🔄 Sincronizar proyectos
                    Button(action: {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncProjects(context: context)
                            withAnimation(.easeOut(duration: 0.3)) {
                                refreshID = UUID()
                                isSyncing = false
                            }
                        }
                    }) {
                        ZStack {
                            if isSyncing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.purple)
                                    .scaleEffect(1.1)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                        }
                        .frame(width: 58, height: 58)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    .disabled(isSyncing)

                    // ➕ Añadir proyecto
                    Button(action: {
                        showAddProjectView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.purple)
                            .frame(width: 58, height: 58)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)

                } else {
                    // 💧 Versiones anteriores sin glassEffect
                    Button(action: {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncProjects(context: context)
                            withAnimation(.easeOut(duration: 0.3)) {
                                refreshID = UUID()
                                isSyncing = false
                            }
                        }
                    }) {
                        ZStack {
                            if isSyncing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.purple)
                                    .scaleEffect(1.1)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 58, height: 58)
                        .background(Circle().fill(Color.purple.opacity(0.9)))
                        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                    }
                    .disabled(isSyncing)

                    Button(action: {
                        showAddProjectView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(Circle().fill(Color.purple.opacity(0.9)))
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                    }
                }
            }

            // 📱 iPhone (compact width)
            else {
                if #available(iOS 26.0, *) {
                    Button(action: {
                        showAddProjectView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.purple)
                            .padding(16)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                } else {
                    Button(action: {
                        showAddProjectView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.9))
                                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            )
                    }
                }
            }
        }
        .padding(.trailing, 30)
            .padding(.bottom, sizeClass == .regular ? 90 :  150)
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
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "folder")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 90)
                .foregroundColor(Color.taskButtonColor.opacity(0.7))
            Text("No hay proyectos disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
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
