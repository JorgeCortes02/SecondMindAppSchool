//
//  ProjectEventMark.swift
//  SecondMind
//
//  Created by Jorge Cortes on 19/9/25.
//

import SwiftUI
import SwiftData
import Foundation

struct ProjectEventMark: View {
    // MARK: – Entornos
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject var utilFunctions: generalFunctions

    // MARK: – Inyección / ViewModel (mantener)
    @Bindable var project: Project
    @StateObject var modelView = EventMarkProjectDetallModelView()

    // MARK: – Estados (mantener nombres y semántica original)
    @State private var selectedData: Date = Date()
    private let accentColor = Color.eventButtonColor

    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false

    // iPad-only: refresco/estado (sin cambiar lógica del VM)
    @State private var refreshID = UUID()
    @State private var isSyncing: Bool = false // 🔄 (comentado el uso real más abajo)

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerCard(title:"Eventos de \(project.title)")
                    .padding(.top, 16)

                // MARK: – Picker adaptado: iPad con barra centrada, iPhone usa el original
                if sizeClass == .regular {
                    HStack(spacing: 10) {
                        segmentButton(title: "Agendados", tag: 0)
                        segmentButton(title: "Finalizados", tag: 1)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.eventButtonColor.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: 360)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    pickerBard
                }

                // MARK: – Contenido scrollable (iPad vs iPhone)
                ScrollView {
                    VStack(spacing: 20) {
                        if sizeClass == .regular {
                            // ===========================
                            // MARK: – iPad Layout
                            // ===========================
                            if modelView.selectedTab == 0 {
                                // AGENDADOS: tarjeta con DatePicker centrado + grid
                                VStack(spacing: 24) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Agendados")
                                                .foregroundColor(.primary)
                                                .font(.title2.weight(.bold))
                                            Spacer()
                                            Text("\(modelView.events.count)")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)

                                        Rectangle()
                                            .fill(Color.primary.opacity(0.1))
                                            .frame(height: 1)

                                        // DatePicker centrado (manteniendo selectedData original)
                                        HStack {
                                            Spacer()
                                            DatePicker(
                                                "",
                                                selection: $selectedData,
                                                in: Date()...,
                                                displayedComponents: [.date]
                                            )
                                            .labelsHidden()
                                            .datePickerStyle(.compact)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 16)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.white.opacity(0.9))
                                                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.eventButtonColor.opacity(0.4), lineWidth: 1)
                                                    )
                                            )
                                            .frame(maxWidth: 300)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .onChange(of: selectedData) {
                                            // Mantener API original del VM
                                            modelView.loadEvents(selectedData: selectedData)
                                        }

                                        if modelView.events.isEmpty {
                                            emptyEventsList()
                                        } else {
                                            // Grid 2 columnas (tarjetas compactas)
                                            LazyVGrid(columns: [GridItem(.flexible()),
                                                                GridItem(.flexible())],
                                                      spacing: 16) {
                                                ForEach(modelView.events, id: \.id) { event in
                                                    EventCardExpanded(event: event)
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
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                // FINALIZADOS: misma tarjeta, sin DatePicker
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Finalizados")
                                            .foregroundColor(.primary)
                                            .font(.title2.weight(.bold))
                                        Spacer()
                                        Text("\(modelView.events.count)")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)

                                    Rectangle()
                                        .fill(Color.primary.opacity(0.1))
                                        .frame(height: 1)

                                    if modelView.events.isEmpty {
                                        emptyEventsList()
                                    } else {
                                        LazyVGrid(columns: [GridItem(.flexible()),
                                                            GridItem(.flexible())],
                                                  spacing: 16) {
                                            ForEach(modelView.events, id: \.id) { event in
                                                EventCardExpanded(event: event)
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
                            }
                        } else {
                            // ===========================
                            // MARK: – iPhone Layout (respetar flujo original)
                            // ===========================
                            if modelView.selectedTab == 0 && showCal {
                                calendarCard(selectedDate: $selectedData)
                            } else if modelView.selectedTab == 0 && !showCal {
                                TaskCard
                            } else if modelView.selectedTab == 1 && showCal {
                                calendarCard(selectedDate: $selectedData)
                            } else if modelView.selectedTab == 1 && !showCal {
                                TaskCard
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
               
                .onChange(of: modelView.selectedTab) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showCal = false
                        switch modelView.selectedTab {
                        case 0:
                            modelView.loadEvents(selectedData: selectedData)
                        case 1:
                            modelView.loadEvents()
                        default:
                            break
                        }
                    }
                }
            }
            // MARK: – Botonera inferior (iPad: 🔄 + ➕ comentado | iPhone: 📅 + ➕)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    buttonControlMark
                }
                
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            // Mantener inicialización original
            modelView.setParameters(context: context, project: project)
            switch modelView.selectedTab {
            case 0:
                modelView.loadEvents(selectedData: selectedData)
            case 1:
                modelView.loadEvents()
            default:
                break
            }
            utilFunctions.pastEvent(eventList: &modelView.events, context: context)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    modelView.readyToShowTasks = true
                }
            }
        }
    }

    // ============================================================
    // MARK: – Segment Control (mismo look & feel que referencia)
    // ============================================================
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (modelView.selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) {
                modelView.selectedTab = tag
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .blue)
                .frame(maxHeight: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    // ============================================================
    // MARK: – Picker bar (iPhone)
    // ============================================================
    private var pickerBard : some View {
        HStack(spacing: 10) {
            segmentButton(title: "Agendados", tag: 0)
            segmentButton(title: "Finalizados", tag: 1)
        }
        .padding(15)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }

    // ============================================================
    // MARK: – Botonera inferior
    //   iPad (regular): 🔄 (comentado) + ➕
    //   iPhone (compact): 📅 (solo en Agendados) + ➕
    // ============================================================
    private var buttonControlMark: some View {
        HStack(spacing: 14) {
            Spacer()

            // 💻 iPad (regular width)
            if sizeClass == .regular {

                // ➕ Añadir (activo)
                if #available(iOS 26.0, *) {
                    Button(action: { showAddTaskView = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.eventButtonColor)
                            .frame(width: 58, height: 58)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    .sheet(isPresented: $showAddTaskView, onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            modelView.loadEvents(selectedData: selectedData)
                            if modelView.selectedTab == 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        modelView.readyToShowTasks = true
                                    }
                                }
                            }
                        }
                    }) {
                        CreateEvent(project: project)
                    }
                } else {
                    Button(action: { showAddTaskView = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.eventButtonColor)
                            .frame(width: 58, height: 58)
                    }
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 3)
                    .sheet(isPresented: $showAddTaskView, onDismiss: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            modelView.loadEvents(selectedData: selectedData)
                            modelView.readyToShowTasks = true
                        }
                    }) {
                        CreateEvent(project: project)
                    }
                }
            }

            // 📱 iPhone (compact width)
            else {
                // 📅 Calendario solo en Agendados
                if modelView.selectedTab == 0 {
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            withAnimation(.easeInOut) { showCal.toggle() }
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.eventButtonColor)
                                .padding(14)
                        }
                        .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                        .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                    } else {
                        Button(action: {
                            withAnimation(.easeInOut) { showCal.toggle() }
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.eventButtonColor.opacity(0.9))
                                        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                                )
                        }
                    }
                }

                // ➕ Añadir (iPhone)
                if #available(iOS 26.0, *) {
                    Button(action: { showAddTaskView = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.eventButtonColor)
                            .padding(16)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                    .sheet(isPresented: $showAddTaskView, onDismiss: {
                        modelView.loadEvents(selectedData: selectedData)
                    }) {
                        CreateEvent(project: project)
                    }
                } else {
                    Button(action: { showAddTaskView = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.eventButtonColor.opacity(0.9))
                                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            )
                    }
                    .sheet(isPresented: $showAddTaskView, onDismiss: {
                        modelView.loadEvents(selectedData: selectedData)
                    }) {
                        CreateEvent(project: project)
                    }
                }
            }
        }
        .padding(.trailing, 30)
        .padding(.bottom,  90)
    }

    // ============================================================
    // MARK: – Tarjeta expandida (iPad grid)
    // ============================================================
    private func EventCardExpanded(event: Event) -> some View {
        NavigationLink(destination: EventDetall(editableEvent: event)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor)

                    Text(event.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .truncationMode(.tail)

                    Spacer()
                }

                if let description = event.descriptionEvent,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("No hay descripción")
                        .font(.system(size: 14).italic())
                        .foregroundColor(.secondary.opacity(0.6))
                        .lineLimit(2)
                }

                if let project = event.project?.title,
                   !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Label(project, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.purple)
                } else {
                    Label("Sin proyecto", systemImage: "folder.badge.questionmark")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }

                Label(utilFunctions.extractHour(event.endDate), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(accentColor)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    // ============================================================
    // MARK: – TaskCard (iPhone contenedor de listas)
    // ============================================================
    private var TaskCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if modelView.selectedTab == 0 {
                    Text(utilFunctions.formattedDate(selectedData))
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else {
                    Text("Eventos finalizados")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                }

                Spacer()
                Text("\(modelView.events.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)

            if modelView.events.isEmpty {
                emptyEventsList()
            } else if modelView.readyToShowTasks {
                if modelView.selectedTab == 1 {
                    endEventsList()
                } else {
                    eventsListToDo()
                }
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            switch modelView.selectedTab {
            case 0:
                modelView.loadEvents(selectedData: selectedData)
            case 1:
                modelView.loadEvents()
            default:
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    modelView.readyToShowTasks = true
                }
            }
        }
        .onChange(of: modelView.selectedTab) {
            withAnimation(.easeInOut(duration: 0.2)) {
                switch modelView.selectedTab {
                case 0:
                    modelView.loadEvents(selectedData: selectedData)
                case 1:
                    modelView.loadEvents()
                default:
                    break
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        modelView.readyToShowTasks = true
                    }
                }
            }
        }
    }

    // ============================================================
    // MARK: – Calendar Card (iPhone)
    // ============================================================
    private func calendarCard(selectedDate: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona fecha")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            DatePicker(
                "",
                selection: $selectedData,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(.horizontal, 20)
            .onChange(of: selectedData) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    modelView.readyToShowTasks = true
                    modelView.loadEvents(selectedData: selectedData)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        modelView.readyToShowTasks = true
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // ============================================================
    // MARK: – Empty state
    // ============================================================
    private func emptyEventsList() -> some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(accentColor.opacity(0.7))

            Text("No hay eventos disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }

    // ============================================================
    // MARK: – Lista de eventos (iPhone, agendados)
    // ============================================================
    private func eventsListToDo() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(modelView.events, id: \.id) { event in
                NavigationLink(destination: EventDetall(editableEvent:event)) {

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            // Título + hora
                            HStack(alignment: .center, spacing: 8) {
                                Text(event.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Spacer()

                                Label {
                                    Text(utilFunctions.extractHour(event.endDate))
                                } icon: {
                                    Image(systemName: "clock")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(accentColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(accentColor.opacity(0.12))
                                .clipShape(Capsule())
                            }

                            // Descripción
                            if let description = event.descriptionEvent,
                               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            } else {
                                Text("No hay descripción")
                                    .font(.system(size: 14).italic())
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .lineLimit(2)
                            }

                            // Proyecto
                            if let project = event.project?.title,
                               !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder")
                                        .font(.system(size: 13))
                                        .foregroundColor(.purple)

                                    Text(project)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.purple)
                                        .lineLimit(1)
                                }
                                .padding(.top, 4)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder.badge.questionmark")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.6))

                                    Text("Sin proyecto")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                .padding(.top, 4)
                            }
                        }

                        Spacer()
                    }
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }

    // ============================================================
    // MARK: – Lista de eventos finalizados (iPhone, agrupados por día)
    // ============================================================
    private func endEventsList() -> some View {
        let groupedEvents = Dictionary(grouping: modelView.events) { event in
            Calendar.current.startOfDay(for: event.endDate)
        }
        let sortedGroups = groupedEvents
            .map { (date: $0.key, events: $0.value) }
            .sorted { $0.date >= $1.date }

        return LazyVStack(spacing: 12) {
            ForEach(sortedGroups, id: \.date) { group in
                VStack {
                    Text("\(utilFunctions.formattedDate(group.date))")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.75, opacity: 0.8),
                                    Color(red: 1.0, green: 0.78, blue: 0.65, opacity: 0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)

                    ForEach(group.events, id: \.id) { event in
                        NavigationLink(destination: EventDetall(editableEvent:event)) {

                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor)
                                    .padding(.top, 4)

                                VStack(alignment: .leading, spacing: 8) {
                                    // Título + hora
                                    HStack(alignment: .center, spacing: 8) {
                                        Text(event.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)

                                        Spacer()

                                        Label {
                                            Text(utilFunctions.extractHour(event.endDate))
                                        } icon: {
                                            Image(systemName: "clock")
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(accentColor)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 10)
                                        .background(accentColor.opacity(0.12))
                                        .clipShape(Capsule())
                                    }

                                    // Descripción
                                    if let description = event.descriptionEvent,
                                       !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(description)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    } else {
                                        Text("No hay descripción")
                                            .font(.system(size: 14).italic())
                                            .foregroundColor(.secondary.opacity(0.6))
                                            .lineLimit(2)
                                    }

                                    // Proyecto
                                    if let project = event.project?.title,
                                       !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "folder")
                                                .font(.system(size: 13))
                                                .foregroundColor(.purple)

                                            Text(project)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.purple)
                                                .lineLimit(1)
                                        }
                                        .padding(.top, 4)
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: "folder.badge.questionmark")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray.opacity(0.6))

                                            Text("Sin proyecto")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                        .padding(.top, 4)
                                    }
                                }

                                Spacer()
                            }
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
    }
}
