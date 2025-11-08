import SwiftUI
import SwiftData
import MapKit

struct CreateEvent: View {
    @State private var newEvent: Event
    @State private var isIncompleteEvent: Bool = false
    
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @ObservedObject var utilFunctions: generalFunctions = generalFunctions()
    @StateObject var viewModel: CreateEventModelView
    
    // Para autocompletado ubicación
    @StateObject private var viewModelLocation = LocationSearchViewModel()
    @FocusState private var locationFieldFocused: Bool
    
    // 🎨 Estética coherente con CreateTask / TaskDetall
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke   = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.2)
    private let fieldBG      = Color(red: 248/255, green: 248/255, blue: 250/255)
    let softRed              = Color(red: 220/255, green: 75/255, blue: 75/255)
    
    init(project: Project? = nil) {
        self._newEvent = State(initialValue: Event(
            title: "",
            endDate: Date(),
            status: .on,
            project: project,
            descriptionEvent: ""
        ))
        _viewModel = StateObject(wrappedValue: CreateEventModelView())
    }
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    // 🧾 Tarjeta principal
                    VStack(spacing: 26) {
                        
                        headerCard
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Título ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Escribe el título", text: $newEvent.title)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
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
                                .padding(.horizontal, 20)
                        }
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Descripción ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: Binding(
                                get: { newEvent.descriptionEvent ?? "" },
                                set: { newEvent.descriptionEvent = $0 }
                            ))
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Picker Proyecto ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proyecto")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Picker("Selecciona un proyecto", selection: $newEvent.project) {
                                Text("Sin proyecto").tag(nil as Project?)
                                ForEach(viewModel.projects, id: \.self) { project in
                                    Text(project.title).tag(project as Project?)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Fecha y hora ———
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fecha y hora del evento")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
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
                            .padding(.horizontal, 10)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Ubicación ———
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ubicación")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 10) {
                                TextField("Buscar dirección", text: $viewModelLocation.queryFragment)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, 8)
                                    .focused($locationFieldFocused)
                                
                                if !viewModelLocation.searchResults.isEmpty {
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 0) {
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
                                    }
                                    .frame(maxHeight: 180)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
                                    )
                                }
                                
                                // Mapa (solo si hay coordenadas)
                                if let lat = newEvent.latitude, let lon = newEvent.longitude {
                                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                    let annotations = [EventAnnotation(coordinate: coord)]
                                    
                                    Map(coordinateRegion: .constant(region), annotationItems: annotations) { item in
                                        MapMarker(coordinate: item.coordinate, tint: .red)
                                    }
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 12).fill(fieldBG))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        Divider().padding(.horizontal, 20)
                        
                        // ——— Botones ———
                        VStack(spacing: 14) {
                            Button(action: saveEvent) {
                                Text("Guardar Evento")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color.eventButtonColor, purpleAccent],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                        .cornerRadius(12)
                                    )
                            }
                            
                            Button(action: { utilFunctions.dismissViewFunc() }) {
                                Text("Cerrar")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(softRed)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
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
                            .stroke(cardStroke, lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
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
        HStack {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.eventButtonColor)
            Text("Crear evento")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.eventButtonColor)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
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
                Task {
                    await SyncManagerUpload.shared.uploadEvent(event: newEvent)
                }
            } catch {
                print("❌ Error al guardar evento: \(error)")
            }
            dismiss()
        }
    }
    
    // Selección del resultado del autocompletado
    @MainActor
    private func selectSuggestion(_ result: MKLocalSearchCompletion) {
        viewModelLocation.search(for: result) { item in
            guard let placemark = item?.placemark else { return }
            
            let direccion = placemark.title ?? result.title
            
            newEvent.address = direccion
            newEvent.latitude = placemark.coordinate.latitude
            newEvent.longitude = placemark.coordinate.longitude
            
            viewModelLocation.setQuery(direccion)
            viewModelLocation.clearResults()
            locationFieldFocused = false
        }
    }
}
