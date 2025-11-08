//
//  EventDetall.swift
//  SecondMind
//
//  Created by Jorge Cortés on 8/6/25.
//

import SwiftUI
import SwiftData
import MapKit

struct EventDetall: View {
    // Entrada
    @Bindable var editableEvent: Event

    // Entorno
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
   
    // VMs
    @StateObject var viewModel: EventDetallModelView
    @StateObject private var viewModelLocation = LocationSearchViewModel()
    
    init(editableEvent: Event) {
        self._editableEvent = Bindable(editableEvent)
        _viewModel = StateObject(wrappedValue: EventDetallModelView())
    }

    // Estilo
    private let fieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)
    private let borderColor = Color.purple.opacity(0.2)
    private let accentColor = Color.purple

    // Estado UI
    @State var isEditing = false
    @State private var showReminderModal: Bool = false
    @State private var isIncompleteTask: Bool = false
    @FocusState private var locationFieldFocused: Bool

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: { showReminderModal = true }) {
                            Image(systemName: "tray.and.arrow.up")
                        }
                        Button(action: {
                            isEditing = true
                            viewModelLocation.queryFragment = editableEvent.address ?? ""
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                locationFieldFocused = true
                            }
                        }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            viewModel.deleteEvent(event: editableEvent)
                            utilFunctions.dismissViewFunc()
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }

            ScrollView {
                VStack(spacing: 32) {
                

                    VStack(spacing: 20) {
                        headerCard
                        titleSection
                        Divider().padding(.horizontal, 20)
                        descriptionAndProjectSection
                        Divider().padding(.horizontal, 20)
                        dateSection
                        Divider().padding(.horizontal, 20)
                        locationSection
                        Divider().padding(.horizontal, 20)
                        notesSection
                        Divider().padding(.horizontal, 20)
                        buttonsSection
                    }
                    .padding(.vertical, 28)
                    .padding(.horizontal, 22)
                    .frame(maxWidth: 800)
                    .background(
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                }
            }
            .onAppear {
                viewModel.setContext(context: context)
                viewModel.getProjects()
            }
            .onChange(of: utilFunctions.dismissView) { value in
                if value { dismiss() }
            }
            .sheet(isPresented: $showReminderModal) {
                SendReminderModal(event: editableEvent)
            }
        }
    }

    // MARK: - HEADER CARD
    private var headerCard: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(accentColor)
            Text("Detalle del Evento")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(accentColor)
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - TITLE SECTION
    private var titleSection: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Título")
                .font(.headline)
                .foregroundColor(.primary)

            if isEditing {
                TextField("Escribe el título", text: $editableEvent.title)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .onChange(of: editableEvent.title) { newValue in
                        if newValue.contains("\n") {
                            editableEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
                        }
                    }

                if isIncompleteTask && editableEvent.title.isEmpty {
                    Text("⚠️ Es obligatorio añadir un título")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                Text(editableEvent.title)
                    .font(.title2)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - DESCRIPTION AND PROJECT
    private var descriptionAndProjectSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Descripción
            VStack(alignment: .leading, spacing: 8) {
                Text("Descripción")
                    .font(.headline)
                    .foregroundColor(.primary)

                if isEditing {
                    TextEditor(text: Binding(
                        get: { editableEvent.descriptionEvent ?? "" },
                        set: { editableEvent.descriptionEvent = $0 }
                    ))
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                } else {
                    Text((editableEvent.descriptionEvent?.isEmpty ?? true)
                         ? "No hay descripción disponible."
                         : editableEvent.descriptionEvent!)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(fieldBackground)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }

            // Proyecto
            VStack(alignment: .leading, spacing: 8) {
                Text("Proyecto")
                    .font(.headline)
                    .foregroundColor(.primary)

                if isEditing {
                    Picker("Selecciona un proyecto", selection: $editableEvent.project) {
                        Text("Sin proyecto").tag(nil as Project?)
                        ForEach(viewModel.projects, id: \.self) { project in
                            Text(project.title).tag(project as Project?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(fieldBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                } else {
                    Text(editableEvent.project?.title ?? "No hay proyecto asignado.")
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(fieldBackground)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - DATE SECTION
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fecha y hora")
                .font(.headline)
                .foregroundColor(.primary)

            if isEditing {
                VStack(alignment: .leading, spacing: 10) {
                    DatePicker(
                        "Selecciona una fecha",
                        selection: $editableEvent.endDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)

                    DatePicker(
                        "Selecciona una hora",
                        selection: $editableEvent.endDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                    Text(utilFunctions.formattedDateAndHour(editableEvent.endDate))
                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(fieldBackground)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - LOCATION SECTION
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ubicación")
                .font(.headline)
                .foregroundColor(.primary)

            if isEditing {
                VStack(spacing: 10) {
                    TextField("Buscar dirección", text: $viewModelLocation.queryFragment)
                        .padding(12)
                        .background(fieldBackground)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
                        .focused($locationFieldFocused)

                    if !viewModelLocation.searchResults.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(viewModelLocation.searchResults, id: \.self) { result in
                                Button {
                                    selectSuggestion(result)
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.title).font(.body)
                                        if !result.subtitle.isEmpty {
                                            Text(result.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                }
                                Divider()
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                        )
                    }

                    mapView
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if let address = editableEvent.address {
                        Text(address)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(fieldBackground)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }

                    mapView
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - MAP VIEW WITH OPEN IN MAPS BUTTON
    private var mapView: some View {
        Group {
            if let lat = editableEvent.latitude,
               let lon = editableEvent.longitude {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let region = MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                let annotations = [EventAnnotation(coordinate: coord)]

                VStack(alignment: .leading, spacing: 10) {
                    Map(
                        coordinateRegion: .constant(region),
                        annotationItems: annotations
                    ) { item in
                        MapMarker(coordinate: item.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)

                    Button(action: {
                        openInMaps()
                    }) {
                        HStack {
                            Image(systemName: "map")
                            Text("Abrir en Mapas")
                        }
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    // MARK: - NOTES SECTION
    private var notesSection: some View {
        NotesCarrousel(editableEvent: editableEvent)
            .padding(.horizontal, 8)
    }

    // MARK: - BUTTONS SECTION
    private var buttonsSection: some View {
        VStack(spacing: 14) {
            NavigationLink(destination: NoteDetailView(event: editableEvent)) {
                Text("Nueva nota")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.noteBlue)
                    .cornerRadius(12)
            }

            Button(action: {
                viewModel.deleteEvent(event: editableEvent)
                utilFunctions.dismissViewFunc()
            }) {
                Text("Eliminar Evento")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.45, blue: 0.75),
                                     Color(red: 0.0, green: 0.35, blue: 0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
            }

            if isEditing {
                Button(action: {
                    viewModel.saveEvent(event: editableEvent)
                    isEditing = false
                    dismiss()
                }) {
                    Text("Guardar Evento")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(accentColor)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - ACTIONS
    private func openInMaps() {
        guard let lat = editableEvent.latitude,
              let lon = editableEvent.longitude else { return }

        let appleMapsURL = URL(string: "http://maps.apple.com/?ll=\(lat),\(lon)")!
        let googleMapsURL = URL(string: "comgooglemaps://?q=\(lat),\(lon)&center=\(lat),\(lon)&zoom=14")!

        if UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL)
        } else {
            UIApplication.shared.open(appleMapsURL)
        }
    }

    @MainActor
    private func selectSuggestion(_ result: MKLocalSearchCompletion) {
        viewModelLocation.search(for: result) { item in
            guard let placemark = item?.placemark else { return }

            let direccion = placemark.title ?? result.title

            editableEvent.address = direccion
            editableEvent.latitude = placemark.coordinate.latitude
            editableEvent.longitude = placemark.coordinate.longitude

            viewModelLocation.queryFragment = direccion
            viewModelLocation.clearResults()
            locationFieldFocused = false

            do {
                try context.save()
                Task {
                    await SyncManagerUpload.shared.uploadEvent(event: editableEvent)
                }
            } catch {
                print("❌ Error guardando ubicación: \(error)")
            }
        }
    }
}
