import SwiftUI
import SwiftData
import MapKit

struct CreateEvent: View {
    // Colores
    let softRed = Color(red: 220/255, green: 75/255, blue: 75/255)
    let textFieldBackground = Color(red: 248/255, green: 248/255, blue: 250/255)

    // Modelo
    @State private var newEvent: Event
    @State private var isIncompleteEvent: Bool = false

    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    @StateObject var viewModel: CreateEventModelView

    // Para autocompletado ubicación
    @StateObject private var viewModelLocation = LocationSearchViewModel()
    @FocusState private var locationFieldFocused: Bool

    init(project: Project? = nil) {
        self._newEvent = State(initialValue: Event(
            name: "",
            endDate: Date(),
            status: .on,
            project: project,
            descriptionEvent: ""
        ))
        _viewModel = StateObject(wrappedValue: CreateEventModelView())
    }

    var body: some View {
        ZStack {
            BackgroundColorTemplate()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                headerCard
                    .padding(.top, 40)

                ScrollView {
                    VStack(spacing: 24) {

                        // Campo título
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            TextField("Escribe el título", text: $newEvent.title)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .onChange(of: newEvent.title) { newValue in
                                    newEvent.title = newValue.replacingOccurrences(of: "\n", with: " ")
                                }
                        }
                        .padding(.horizontal, 20)

                        if isIncompleteEvent {
                            Text("⚠️ Es obligatorio añadir un título")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        // Campo descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            TextEditor(text: Binding(
                                get: { newEvent.descriptionEvent ?? "" },
                                set: { newEvent.descriptionEvent = $0 }
                            ))
                            .frame(minHeight: 120)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        // Picker de proyecto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proyecto")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Picker("Selecciona un proyecto", selection: $newEvent.project) {
                                Text("Sin proyecto").tag(nil as Project?)
                                ForEach(viewModel.projects, id: \.self) { project in
                                    Text(project.title).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        // Fecha y hora
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fecha y hora del evento")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 12) {
                                DatePicker(
                                    "Selecciona una fecha",
                                    selection: Binding(
                                        get: { newEvent.endDate ?? Date() },
                                        set: { newEvent.endDate = $0 }
                                    ),
                                    in: Date()...,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)

                                DatePicker(
                                    "Selecciona una hora",
                                    selection: Binding(
                                        get: { newEvent.endDate ?? Date() },
                                        set: { newEvent.endDate = $0 }
                                    ),
                                    displayedComponents: [.hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 14).fill(textFieldBackground))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        // Ubicación
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ubicación")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            VStack(spacing: 10) {
                                // Buscador
                                TextField("Buscar dirección", text: $viewModelLocation.queryFragment)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, 8)
                                    .focused($locationFieldFocused)

                                // Sugerencias
                                if !viewModelLocation.searchResults.isEmpty {
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 0) {
                                            ForEach(viewModelLocation.searchResults, id: \.self) { result in
                                                Button {
                                                    selectSuggestion(result)
                                                } label: {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(result.title)
                                                            .font(.body)
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
                                                .background(Color.white.opacity(0.001))
                                                Divider()
                                            }
                                        }
                                    }
                                    .frame(maxHeight: 180)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                                    )
                                }

                                // Mini-mapa
                                if let lat = newEvent.latitude,
                                   let lon = newEvent.longitude {
                                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    let region = MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                    let annotations = [EventAnnotation(coordinate: coord)]

                                    Map(
                                        coordinateRegion: .constant(region),
                                        annotationItems: annotations
                                    ) { item in
                                        MapMarker(coordinate: item.coordinate, tint: .red)
                                    }
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(12)
                            .background(textFieldBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)

                        // Botones
                        VStack(spacing: 14) {
                            Button(action: saveEvent) {
                                Text("Guardar Evento")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.eventButtonColor, .purple],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                        .cornerRadius(14)
                                    )
                            }

                            Button(action: { utilFunctions.dismissViewFunc() }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 14).fill(softRed))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            viewModel.setContext(context: context)
            viewModel.loadProjects()
        }
        .onChange(of: utilFunctions.dismissView) { value in
            if value { dismiss() }
        }
    }

    private var headerCard: some View {
        Text("Crear evento")
            .font(.system(size: 30, weight: .bold))
            .foregroundColor(.eventButtonColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [Color.white, Color.eventButtonColor.opacity(0.08)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
            )
            .padding(.horizontal, 20)
    }

    private func saveEvent() {
        if newEvent.title.isEmpty {
            isIncompleteEvent = true
        } else {
            context.insert(newEvent)
            if let project = newEvent.project {
                project.events.append(newEvent)
            }
            do {
                try context.save()
            } catch {
                print("❌ Error al guardar evento: \(error)")
            }
            dismiss()
        }
    }

    // Selección de dirección
    @MainActor
    private func selectSuggestion(_ result: MKLocalSearchCompletion) {
        viewModelLocation.search(for: result) { item in
            guard let placemark = item?.placemark else { return }

            let direccion = placemark.title ?? result.title

            // Actualiza el evento nuevo
            newEvent.address = direccion
            newEvent.latitude = placemark.coordinate.latitude
            newEvent.longitude = placemark.coordinate.longitude

            // Refresca buscador y oculta sugerencias
            viewModelLocation.setQuery(direccion)
            viewModelLocation.clearResults()
            locationFieldFocused = false
        }
    }
}
