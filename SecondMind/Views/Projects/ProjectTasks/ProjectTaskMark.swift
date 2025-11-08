import SwiftUI
import SwiftData
import Foundation

struct ProjectTaskMark<ViewModel: BaseTaskViewModel>: View {
    
    
    @StateObject var modelView = TaskMarkProjectDetallModelView()
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @Bindable var project: Project
    @State private var selectedData: Date = Date()
    private let accentColor = Color.taskButtonColor
    
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing = false
    @State private var refreshID = UUID()
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 20) {
                headerCard(title: "Tareas de \(project.title)")
                    .padding(.top, 16)
                
                if sizeClass == .regular {
                    PickerBar(options: ["Activas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                } else {
                    PickerBar(options: ["Sin fecha", "Agendadas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                }
                
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ===========================
                        //   iPad (2 columnas, 800px)
                        // ===========================
                        if sizeClass == .regular {
                            TasksSectionsiPadView(
                                modelView: modelView,
                                accentColor: accentColor
                            )
                        }
                        
                        // ===========================
                        //   iPhone (lista vertical + Calendar opcional)
                        // ===========================
                        else {
                            if modelView.selectedTab == 1 && showCal {
                                calendarCard(selectedDate: $modelView.selectedData)
                            } else {
                                TasksElementsListView(
                                    modelView: modelView,
                                    accentColor: accentColor
                                )
                            }
                        }
                        
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
                .refreshable {
                    await syncAndReload()
                }
            }
            .safeAreaInset(edge: .bottom) {
                buttonControlMark
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: modelView.selectedTab){
                modelView.loadTasks()
            }
            .onChange(of: modelView.selectedData) {
                if modelView.selectedTab == 1 {
                    modelView.loadTasks()
                }
            }
            .onAppear {
                
                if sizeClass == .regular {
                    modelView.setParameters(context: context, project :  project, sizeClass: .regular)
                }else{
                    modelView.setParameters(context: context, project :  project, sizeClass: .compact)
                }
                
               
                modelView.loadTasks()
            }
            .sheet(isPresented: $showAddTaskView, onDismiss: {
                modelView.loadTasks()
            }) {
                CreateTask(project: project)
            }
        }
    }
    
    // MARK: - Botonera inferior
    private var buttonControlMark: some View {
        glassButtonBar(
            funcAddButton: { showAddTaskView = true },
            funcSyncButton: { Task { await syncAndReload() } },
            funcCalendarButton: {
                withAnimation { showCal.toggle() }
            },
            color: accentColor,
            selectedTab: $modelView.selectedTab,
            isSyncing: $isSyncing
        )
    }
    
    // MARK: - Calendar Card
    private func calendarCard(selectedDate: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filtrar por fecha")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            DatePicker(
                "",
                selection: selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(.horizontal, 20)
            .onChange(of: modelView.selectedData) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    modelView.loadTasks()
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Sincronización
    private func syncAndReload() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncAll(context: context)
        modelView.loadTasks()
        withAnimation {
            refreshID = UUID()
            isSyncing = false
        }
    }}
