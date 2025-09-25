import MapKit

class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var queryFragment: String = "" {
        didSet {
            if queryFragment != oldValue { // evita loops infinitos
                completer.queryFragment = queryFragment
            }
        }
    }
    @Published var searchResults: [MKLocalSearchCompletion] = []

    private let completer: MKLocalSearchCompleter

    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Autocompletado falló: \(error.localizedDescription)")
    }

    func search(for completion: MKLocalSearchCompletion, completionHandler: @escaping (MKMapItem?) -> Void) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            completionHandler(response?.mapItems.first)
        }
    }

    /// ⚡ Forzar seteo de query aunque sea el mismo texto
    func setQuery(_ text: String) {
        queryFragment = text
        completer.queryFragment = text
    }

    /// ⚡ Limpiar resultados y resetear query
    func clearResults() {
        searchResults = []
        completer.queryFragment = ""
    }
}
