import SwiftUI
import SwiftData

struct EventMark: View {
  
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    @StateObject private var modelView: EventMarkModelView
    @State private var refreshID = UUID()
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing: Bool = false
    
    private let accentColor = Color.eventButtonColor
    private let fieldBG = Color(red: 248/255, green: 248/255, blue: 250/255)
    
    init() {
        _modelView = StateObject(wrappedValue: EventMarkModelView())
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        // Cabecera visual coherente
                        headerCard(title: "Eventos", accentColor: accentColor, sizeClass: sizeClass)
                            .padding(.top, 8).padding(.bottom, 26)
                        
                        // Selector superior
                        PickerBar(options: ["Agendados", "Finalizados"], selectedTab: $modelView.selectedTab).padding(.bottom,0
                        )
                        
                        // Contenido principal
                        VStack(spacing: 18) {
                            if sizeClass == .regular {
                                // iPad
                                if modelView.selectedTab == 0 {
                                    EventListSection(
                                        modelView: modelView,
                                        title: "Agendados",
                                        accentColor: accentColor,
                                        selectedDate: $modelView.selectedData,
                                        isDateFilterEnabled: true,
                                        isIpad: true
                                    )
                                } else {
                                    FinalizedEventListSection(
                                        modelView: modelView,
                                        accentColor: accentColor,
                                        isIpad: true
                                    )
                                }
                            } else {
                                // iPhone
                                if modelView.selectedTab == 0 && showCal {
                                    calendarCard(selectedDate: $modelView.selectedData)
                                    Spacer()
                                } else if modelView.selectedTab == 0 {
                                    EventListSection(
                                        modelView: modelView,
                                        title: "Agendados",
                                        accentColor: accentColor,
                                        selectedDate: $modelView.selectedData,
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
                    await syncFromServer()
                }
                .ignoresSafeArea(edges: .bottom)
                .onChange(of: modelView.selectedTab) { _ in
                    withAnimation(.easeInOut) {
                        showCal = false
                        loadEvents()
                    }
                }
                .onChange(of: modelView.selectedData) { _ in
                    withAnimation(.easeInOut) {
                        showCal = false
                        loadEvents()
                    }
                }
                .onAppear {
                    modelView.setContext(context)
                    loadEvents()
                    utilFunctions.pastEvent(eventList: &modelView.events, context: context)
                }
                .sheet(isPresented: $showAddTaskView, onDismiss: { loadEvents() }) {
                    CreateEvent()
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    loadEvents()
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
    
    // MARK: – Funciones de utilidad
    private func loadEvents() {
        modelView.loadEvents()
        utilFunctions.pastEvent(eventList: &modelView.events, context: context)
    }
    
    private func syncFromServer() async {
        isSyncing = true
        await SyncManagerDownload.shared.syncAll(context: context)
        loadEvents()
        withAnimation(.easeOut(duration: 0.3)) {
            refreshID = UUID()
            isSyncing = false
        }
    }
}
