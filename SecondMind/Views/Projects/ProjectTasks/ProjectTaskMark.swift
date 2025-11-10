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
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing = false
    @State private var refreshID = UUID()
    
    private let accentColor = Color.taskButtonColor
    private let fieldBG = Color(red: 248/255, green: 248/255, blue: 250/255)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 26) {
                        
                        // Cabecera visual coherente
                        headerCard(title: "Tareas", accentColor: accentColor, sizeClass: sizeClass)
                            .padding(.top, 8)
                        
                        
                   
                            PickerBar(options: ["Sin fecha", "Agendadas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                        
                        
                        // Contenido principal de las tareas
                        VStack(spacing: 18) {
                            if sizeClass == .regular {
                                // iPad → grid de secciones
                                TasksSectionsiPadView(
                                    modelView: modelView,
                                    accentColor: accentColor
                                )
                            } else {
                                // iPhone → lista compacta o calendario
                                if modelView.selectedTab == 1 && showCal {
                                    calendarCard(selectedDate: $modelView.selectedData)
                                    Spacer()
                                } else {
                                    TasksElementsListView(
                                        modelView: modelView,
                                        accentColor: accentColor
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .padding(.top, 10)
                    }
                    .padding(.vertical, 26)
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
                    await syncAndReload()
                }
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: modelView.selectedTab) {
                    modelView.loadTasks()
                }
                .onChange(of: modelView.selectedData) {
                    if modelView.selectedTab == 1 {
                        modelView.loadTasks()
                    }
                }
                .onAppear {
                    
                        modelView.setParameters(context: context, project: project)
                   
                    modelView.loadTasks()
                }
                .sheet(isPresented: $showAddTaskView, onDismiss: {
                    modelView.loadTasks()
                }) {
                    CreateTask(project: project)
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
 
    
    // MARK: – Calendar Card
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
            .onChange(of: modelView.selectedData) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    modelView.loadTasks()
                }
            }
        }
        .padding(.vertical, 12)
        .background(fieldBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: – Botonera inferior
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
    
    // MARK: – Sincronización
    private func syncAndReload() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncAll(context: context)
        modelView.loadTasks()
        withAnimation {
            refreshID = UUID()
            isSyncing = false
        }
    }
}
