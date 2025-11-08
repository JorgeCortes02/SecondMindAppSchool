import SwiftUI
import SwiftData

struct EventMark: View {
  
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject private var modelView: EventMarkModelView
    @State private var refreshID = UUID()
    
    init() {
        _modelView = StateObject(wrappedValue: EventMarkModelView())
    }
    
 
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing: Bool = false
    
    private let accentColor = Color.eventButtonColor
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerCard(title: "Eventos")
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
                }.onChange(of: modelView.selectedData) { _ in
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
            modelView.setContext(context)
            loadEvents()
            utilFunctions.pastEvent(eventList: &modelView.events, context: context)
        }
        .sheet(isPresented: $showAddTaskView, onDismiss: { loadEvents() }) {
            CreateEvent()
        }
    }
    
    private func loadEvents() {
       
            modelView.loadEvents()
        utilFunctions.pastEvent(eventList: &modelView.events, context: context)
    }
    
    private func syncFromServer() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncAll(context: context)
        withAnimation(.easeOut(duration: 0.3)) {
            refreshID = UUID()
            isSyncing = false
        }
        utilFunctions.pastEvent(eventList: &modelView.events, context: context)
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
