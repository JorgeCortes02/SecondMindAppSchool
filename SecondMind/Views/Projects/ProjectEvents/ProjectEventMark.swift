import SwiftUI
import SwiftData
import Foundation

struct ProjectEventMark: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    @Bindable var project: Project
    @StateObject var modelView = EventMarkProjectDetallModelView()
    
  
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing: Bool = false
    @State private var refreshID = UUID()

    private let accentColor = Color.eventButtonColor
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerCard(title: "Eventos de \(project.title)")
                    .padding(.top, 16)

                PickerBar(options: ["Agendados", "Finalizados"], selectedTab: $modelView.selectedTab)

                ScrollView {
                    VStack(spacing: 20) {
                        if sizeClass == .regular {
                            
                            
                            if modelView.selectedTab == 0 {
                                
                                EventListSection(
                                    modelView: modelView,
                                    title: modelView.selectedTab == 0 ? "Agendados" : "Finalizados",
                                    accentColor: accentColor,
                                    selectedDate: $modelView.selectedData ,
                                    isDateFilterEnabled: modelView.selectedTab == 0,
                                    isIpad: true
                                )
                                
                            }else{
                                
                                FinalizedEventListSection(
                                    modelView: modelView,
                                    accentColor: accentColor,
                                    isIpad: true
                                )
                                
                                
                            }
                            
                           
                        } else {
                            if modelView.selectedTab == 0 && showCal {
                                EventCalendarCard(
                                    modelView: modelView,
                                    selectedDate: $modelView.selectedData,
                                    accentColor: accentColor,
                                    showCal: $showCal
                                )
                            }else if modelView.selectedTab == 0{
                                
                                EventListSection(
                                    modelView: modelView,
                                    title: "Agendados",
                                    accentColor: accentColor,
                                    selectedDate: $modelView.selectedData ,
                                    isDateFilterEnabled: false,
                                    isIpad: false
                                )
                                
                            } else {
                                FinalizedEventListSection(
                                    modelView: modelView,
                                    accentColor: accentColor,
                                    isIpad: false
                                )
                                
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
                .refreshable {
                    await syncFromServer()
                }
                .onChange(of: modelView.selectedTab) { _ in
                    withAnimation(.easeInOut) {
                        showCal = false
                        loadEvents()
                    }
                
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    buttonControlMark
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            modelView.setParameters(context: context, project: project)
            modelView.loadEvents()
        }
        .sheet(isPresented: $showAddTaskView, onDismiss: { modelView.loadEvents(); print ("cargodo juju") }) {
            CreateEvent(project: project)
        }
    }

    private func loadEvents() {
        switch modelView.selectedTab {
        case 0:
            modelView.loadEvents()
        case 1:
            modelView.loadEvents()
        default:
            break
        }
    }
    
    private func syncFromServer() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncAll(context: context)
        withAnimation(.easeOut(duration: 0.3)) {
            refreshID = UUID()
            isSyncing = false
        }
    }
    
    // Mantienes tu botonera tal como estaba ✅
    private var buttonControlMark: some View {
        glassButtonBar(
            funcAddButton: { showAddTaskView = true },
            funcSyncButton: {
                Task {
                    await syncFromServer()
                }
            },
            funcCalendarButton: {
                withAnimation(.easeInOut) { showCal.toggle() }
            },
            color: accentColor,
            selectedTab: $modelView.selectedTab,
            isSyncing: $isSyncing
        )
    }
}
