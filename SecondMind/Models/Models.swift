import Foundation
import SwiftData
import CoreLocation
// MARK: - Enums
enum ActivityStatus: String, Codable {
    case on
    case off
}

// MARK: - Project
@Model
class Project {
    var title: String
    var endDate: Date?
    @Attribute var status: ActivityStatus
    var lastOpenedDate: Date
    var descriptionProject: String?

    // 1 Project → * Events
    @Relationship(deleteRule: .cascade, inverse: \Event.project)
    var events: [Event] = []

    // 1 Project → * TaskItems
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []

    // 🔹 1 Project → * Notes
    @Relationship(deleteRule: .cascade, inverse: \NoteItem.project)
    var notes: [NoteItem] = []

    init(
        title: String,
        endDate: Date? = nil,
        status: ActivityStatus = .on,
        description: String? = nil
    ) {
        self.title = title
        self.endDate = endDate
        self.status = status
        self.descriptionProject = description
        self.lastOpenedDate = Date()
    }
}

// MARK: - Event

@Model
class Event {
    var title: String
    var endDate: Date
    @Attribute var status: ActivityStatus
    var descriptionEvent: String?

    // * Event → 1 Project
    @Relationship(deleteRule: .nullify)
    var project: Project?

    // 1 Event → * TaskItems
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.event)
    var tasks: [TaskItem] = []

    // 1 Event → * Documents
    @Relationship(deleteRule: .cascade, inverse: \UploadedDocument.event)
    var documents: [UploadedDocument] = []

    // 1 Event → * Notes
    @Relationship(deleteRule: .cascade, inverse: \NoteItem.event)
    var notes: [NoteItem] = []
    
    // 🔹 Ubicación
    var address: String?         // Nombre/dirección
    var latitude: Double?        // Coordenada latitud
    var longitude: Double?       // Coordenada longitud
    
    // Propiedad calculada para trabajar fácil con CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    init(
        name: String,
        endDate: Date,
        status: ActivityStatus = .on,
        project: Project? = nil,
        descriptionEvent: String? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.title = name
        self.endDate = endDate
        self.status = status
        self.project = project
        self.descriptionEvent = descriptionEvent
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
// MARK: - NoteItem
@Model
class NoteItem {
    var title: String
    var content: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var isArchived: Bool

    // 🔹 * Note → 1 Project (opcional)
    @Relationship(deleteRule: .nullify)
    var project: Project?

    // 🔹 * Note → 1 Event (opcional)
    @Relationship(deleteRule: .nullify)
    var event: Event?

    init(
        title: String,
        content: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false,
        isArchived: Bool = false,
        project: Project? = nil,
        event: Event? = nil
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.project = project
        self.event = event
    }
}




// MARK: - TaskItem
@Model
class TaskItem {
    var title: String
    var endDate: Date?
    var completeDate: Date?
    var createDate = Date()
    @Attribute var status: ActivityStatus
    var descriptionTask: String?

    // * TaskItem → 1 Project (directa)
    @Relationship(deleteRule: .nullify)
    var project: Project?

    // * TaskItem → 1 Event (directa)
    @Relationship(deleteRule: .nullify)
    var event: Event?

    init(
        title: String,
        endDate: Date? = nil,
        project: Project? = nil,
        event: Event? = nil,
        status: ActivityStatus = .on,
        descriptionTask: String? = nil,
        completeDate: Date? = nil
    ) {
        self.title = title
        self.endDate = endDate
        self.project = project
        self.event = event
        self.status = status
        self.descriptionTask = descriptionTask
        self.completeDate = completeDate
    }
}

// MARK: - UploadedDocument
@Model
class UploadedDocument {
    var title: String
    var localURL: URL
    var uploadDate: Date

    // * Document → 1 Event (directa)
    @Relationship(deleteRule: .nullify)
    var event: Event?

    init(title: String, localURL: URL, event: Event? = nil) {
        self.title = title
        self.localURL = localURL
        self.uploadDate = Date()
        self.event = event
    }
}

// MARK: - Note


// MARK: - LastDeleteTask
@Model
class lastDeleteTask {
    var date: Date?

    init(date: Date?) {
        self.date = date
    }
}



