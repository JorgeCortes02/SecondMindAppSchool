import Foundation
import SwiftData
import CoreLocation

// ============================================================
// MARK: - Helper para recuperar el token actual
// ============================================================
struct CurrentUser {
    static func token() -> String {
        guard let data = KeychainHelper.standard.read(
            service: "SecondMindUserId",
            account: "SecondMind"
        ),
        let token = String(data: data, encoding: .utf8) else {
            return "unknown"
        }
        print(token)
        return token
    }
}
// ============================================================
// MARK: - Enums
// ============================================================
enum ActivityStatus: String, Codable {
    case on
    case off
}

// ============================================================
// MARK: - Project
// ============================================================
@Model
class Project {
    var externalId: UUID?
    var token: String   // 👈 Asociado al usuario

    var title: String
    var endDate: Date?
    @Attribute var status: ActivityStatus
    var lastOpenedDate: Date
    var descriptionProject: String?

    // Relaciones
    @Relationship(deleteRule: .cascade, inverse: \Event.project)
    var events: [Event] = []

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []

    @Relationship(deleteRule: .cascade, inverse: \NoteItem.project)
    var notes: [NoteItem] = []

    init(
        title: String,
        endDate: Date? = nil,
        status: ActivityStatus = .on,
        description: String? = nil,
        externalId: UUID? = nil,
        token: String = CurrentUser.token()
    ) {
        print("El token: " + token)
        self.title = title
        self.endDate = endDate
        self.status = status
        self.descriptionProject = description
        self.lastOpenedDate = Date()
        self.externalId = externalId ?? UUID()
        self.token = token
    }
}

// ============================================================
// MARK: - Event
// ============================================================
@Model
class Event {
    var externalId: UUID?
    var token: String   // 👈 Asociado al usuario

    var title: String
    var endDate: Date
    @Attribute var status: ActivityStatus
    var descriptionEvent: String?

    // Relaciones
    @Relationship(deleteRule: .nullify)
    var project: Project?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.event)
    var tasks: [TaskItem] = []

    @Relationship(deleteRule: .cascade, inverse: \UploadedDocument.event)
    var documents: [UploadedDocument] = []

    @Relationship(deleteRule: .cascade, inverse: \NoteItem.event)
    var notes: [NoteItem] = []

    // Localización
    var address: String?
    var latitude: Double?
    var longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    init(
        title: String,
        endDate: Date,
        status: ActivityStatus = .on,
        project: Project? = nil,
        descriptionEvent: String? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        externalId: UUID? = nil,
        token: String = CurrentUser.token()
    ) {
        self.title = title
        self.endDate = endDate
        self.status = status
        self.project = project
        self.descriptionEvent = descriptionEvent
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.externalId = externalId ?? UUID()
        self.token = token
    }
}

// ============================================================
// MARK: - NoteItem
// ============================================================
@Model
class NoteItem {
    var externalId: UUID?
    var token: String   // 👈 Asociado al usuario

    var title: String
    var content: String?
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var isArchived: Bool

    @Relationship(deleteRule: .nullify)
    var project: Project?

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
        event: Event? = nil,
        externalId: UUID? = nil,
        token: String = CurrentUser.token()
    ) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.project = project
        self.event = event
        self.externalId = externalId ?? UUID()
        self.token = token
    }
}

// ============================================================
// MARK: - TaskItem
// ============================================================
@Model
class TaskItem {
    var externalId: UUID?
    var token: String   // 👈 Asociado al usuario

    var title: String
    var endDate: Date?
    var completeDate: Date?
    var createDate = Date()
    @Attribute var status: ActivityStatus
    var descriptionTask: String?

    @Relationship(deleteRule: .nullify)
    var project: Project?

    @Relationship(deleteRule: .nullify)
    var event: Event?

    init(
        title: String,
        endDate: Date? = nil,
        project: Project? = nil,
        event: Event? = nil,
        status: ActivityStatus = .on,
        descriptionTask: String? = nil,
        completeDate: Date? = nil,
        externalId: UUID? = nil,
        token: String = CurrentUser.token()
    ) {
        self.title = title
        self.endDate = endDate
        self.project = project
        self.event = event
        self.status = status
        self.descriptionTask = descriptionTask
        self.completeDate = completeDate
        self.externalId = externalId ?? UUID()
        self.token = token
    }
}

// ============================================================
// MARK: - UploadedDocument
// ============================================================
@Model
class UploadedDocument {
    var externalId: UUID?
    var token: String   // 👈 Asociado al usuario

    var title: String
    var localURL: URL
    var uploadDate: Date

    @Relationship(deleteRule: .nullify)
    var event: Event?

    init(
        title: String,
        localURL: URL,
        event: Event? = nil,
        externalId: UUID? = nil,
        token: String = CurrentUser.token()
    ) {
        self.title = title
        self.localURL = localURL
        self.uploadDate = Date()
        self.event = event
        self.externalId = externalId ?? UUID()
        self.token = token
    }
}

// ============================================================
// MARK: - LastDeleteTask
// ============================================================
@Model
class LastDeleteTask {
    var date: Date?
    var token: String   // 👈 Asociado al usuario

    init(
        date: Date?,
        token: String = CurrentUser.token()
    ) {
        self.date = date
        self.token = token
    }
}
