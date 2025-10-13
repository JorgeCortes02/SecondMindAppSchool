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
    let textFieldBackground = Color(red: 240/255, green: 240/255, blue: 245/255)

    // Estado UI
    @State var isEditing = false
    @State private var showReminderModal: Bool = false
    @State private var isIncompleteTask: Bool = false
    @FocusState private var locationFieldFocused: Bool

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
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

            VStack(spacing: 10) {
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                Spacer()

                ScrollView {
                    VStack(spacing: 32) {
                        contentView
                    }
                    .background(Color.white)
                    .cornerRadius(40)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                    // ✅ Centrado en iPad, igual en iPhone
                    .frame(maxWidth: sizeClass == .regular ? 900 : .infinity)
                    .padding(.horizontal, sizeClass == .regular ? 50 : 0)
                }

                Spacer()
            }
            .sheet(isPresented: $showReminderModal) {
                SendReminderModal(event: editableEvent)
            }
            .onAppear {
                viewModel.setContext(context: context)
                viewModel.getProjects()
            }
            .onChange(of: utilFunctions.dismissView) { value in
                if value { dismiss() }
            }
        }
    }

    // MARK: - Contenido principal
    private var contentView: some View {
        VStack(spacing: 32) {
            // MARK: Título
            if isEditing {
                VStack(alignment: .leading) {
                    Text("Titulo")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)

                    TextEditor(text: $editableEvent.title)
                        .font(.body)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 12).fill(textFieldBackground)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        .onChange(of: editableEvent.title) { newValue in
                            if newValue.contains("\n") {
                                editableEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
                            }
                        }

                    HStack {
                        Spacer()
                        if isIncompleteTask {
                            Text("Es obligatorio añadir un título")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            } else {
                Text(editableEvent.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding()
                    .opacity(0.9)
                    .padding(.top, 20)
            }

            // MARK: Descripción + Proyecto
            VStack(alignment: .leading, spacing: 36) {
                // Descripción
                VStack(alignment: .leading) {
                    Text("Descripción")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)

                    if isEditing {
                        TextEditor(text: Binding(
                            get: { editableEvent.descriptionEvent ?? "" },
                            set: { editableEvent.descriptionEvent = $0 }
                        ))
                        .font(.body)
                        .foregroundColor(.primary)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .frame(minHeight: 100)
                        .background(RoundedRectangle(cornerRadius: 12).fill(textFieldBackground))
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                    } else {
                        Text((editableEvent.descriptionEvent?.isEmpty ?? true)
                             ? "No hay descripción disponible."
                             : editableEvent.descriptionEvent!)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(textFieldBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Proyecto
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Proyecto")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)

                        if isEditing {
                            Picker("Selecciona un proyecto", selection: $editableEvent.project) {
                                Text("Sin proyecto").tag(nil as Project?)
                                ForEach(viewModel.projects, id: \.self) { project in
                                    Text(project.title).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(textFieldBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        } else {
                            Text(editableEvent.project?.title ?? "No hay proyecto.")
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(textFieldBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            // MARK: Fecha
            VStack(alignment: .leading, spacing: 8) {
                Text("Fecha de vencimiento")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)

                if isEditing {
                    VStack(spacing: 8) {
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
                    .padding(.bottom, 16)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.orange)

                        Text(utilFunctions.formattedDateAndHour(editableEvent.endDate))
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(textFieldBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                    .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 16)

            // MARK: Ubicación
            VStack(alignment: .leading, spacing: 12) {
                Text("Ubicación")
                    .font(.headline)
                    .foregroundColor(.primary)

                if isEditing {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Buscar dirección", text: $viewModelLocation.queryFragment)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(textFieldBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
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
                                        .frame(maxWidth: .infinity, alignment: .leading)
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

                        if let lat = editableEvent.latitude,
                           let lon = editableEvent.longitude {
                            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            let annotations = [EventAnnotation(coordinate: coord)]
                            Map(coordinateRegion: .constant(region), annotationItems: annotations) { item in
                                MapMarker(coordinate: item.coordinate, tint: .red)
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(editableEvent.address ?? "No hay dirección.")
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(textFieldBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)

                        if let lat = editableEvent.latitude,
                           let lon = editableEvent.longitude {
                            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                            let annotations = [EventAnnotation(coordinate: coord)]
                            Map(coordinateRegion: .constant(region), annotationItems: annotations) { item in
                                MapMarker(coordinate: item.coordinate, tint: .red)
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 4)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            // MARK: Notas
            NotesCarrousel(editableEvent: editableEvent)
                .padding(.horizontal, 8)

            // MARK: Botones
            VStack(spacing: 16) {
                NavigationLink(destination: NoteDetailView(event: editableEvent)) {
                    Label("Nueva nota", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }

                Button(action: {
                    viewModel.deleteEvent(event: editableEvent)
                    utilFunctions.dismissViewFunc()
                }) {
                    Text("Eliminar Evento")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 0.0, green: 0.45, blue: 0.75),
                                Color(red: 0.0, green: 0.35, blue: 0.65)
                            ]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing)
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(ScaleButtonStyle())

                if isEditing {
                    Button(action: {
                        viewModel.saveEvent(event: editableEvent)
                        isEditing = false
                        dismiss()
                    }) {
                        Text("Guardar Evento")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.eventButtonColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.eventButtonColor, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Actions
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
