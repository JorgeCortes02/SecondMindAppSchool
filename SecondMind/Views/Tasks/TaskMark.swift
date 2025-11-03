import SwiftUI
import SwiftData

struct TaskMark: View {
    
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @StateObject private var modelView: TaskViewModel
    
    @State private var refreshID = UUID()
    @State private var isSyncing = false
    
    private let accentColor = Color.taskButtonColor
    
    init() {
        _modelView = StateObject(wrappedValue: TaskViewModel())
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                headerCard(title: "Tareas")
                    .padding(.top, 16)
                
                if sizeClass == .regular {
                    PickerBar(options: ["Activas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                } else {
                    PickerBar(options: ["Sin fecha", "Agendadas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        if sizeClass == .regular {
                            // iPad → secciones en grid
                            TasksSectionsiPadView(modelView: modelView, accentColor: accentColor)
                        } else {
                            // iPhone → lista compacta + Calendar Card opcional
                            if modelView.selectedTab == 1 && modelView.showCal {
                                calendarCard(selectedDate: $modelView.selectedData)
                            } else {
                                TasksElementsListView(modelView: modelView)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
                .refreshable {
                    await refreshTasksFromServer()
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack { Spacer(); buttonControlMark }
            }
            .ignoresSafeArea(.keyboard)
            .onAppear {
                modelView.setContext(context)
                modelView.loadTasks() // usa selectedTab/selectedData internamente
            }
            .onChange(of: modelView.selectedTab) { _ in
                modelView.loadTasks()
            }
            .onChange(of: modelView.selectedData) { _ in
                // 🔐 Solo recarga si estás en “Agendadas”
                if modelView.selectedTab == 1 {
                    modelView.loadTasks()
                }
            }
            .sheet(isPresented: $modelView.showAddTaskView, onDismiss: {
                modelView.loadTasks()
            }) {
                CreateTask()
            }
        }
    }
    
    // MARK: – Botonera inferior
    private var buttonControlMark: some View {
        glassButtonBar(
            funcAddButton: { modelView.showAddTaskView = true },
            funcSyncButton: { Task { await refreshTasksFromServer() } },
            funcCalendarButton: {
                withAnimation(.easeInOut) { modelView.showCal.toggle() }
            },
            color: accentColor,
            selectedTab: $modelView.selectedTab,
            isSyncing: $isSyncing
        )
    }
    
    // MARK: – Calendar Card (iPhone, tab = Agendadas)
    private func calendarCard(selectedDate: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona fecha")
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
                // Al cambiar la fecha, oculta el calendario y recarga SOLO en tab=1
                withAnimation(.easeInOut(duration: 0.3)) {
                    modelView.showCal = false
                    if modelView.selectedTab == 1 {
                        modelView.loadTasks()
                    }
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
    
    // MARK: – Utilidad: refetch y refresh
    private func refreshTasksFromServer() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncTasks(context: context)
        modelView.loadTasks()
        withAnimation(.easeOut(duration: 0.3)) {
            refreshID = UUID()
            isSyncing = false
        }
    }
}
