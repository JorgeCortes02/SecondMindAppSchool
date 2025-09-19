import Foundation
import SwiftData

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

    // * Event → 1 Project (directa)
    @Relationship(deleteRule: .nullify)
    var project: Project?

    // 1 Event → * TaskItems (inversa)
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.event)
    var tasks: [TaskItem] = []

    // 1 Event → * Documents (inversa)
    @Relationship(deleteRule: .cascade, inverse: \UploadedDocument.event)
    var documents: [UploadedDocument] = []

   

    init(
        name: String,
        endDate: Date,
        status: ActivityStatus = .on,
        project: Project? = nil,
        descriptionEvent: String? = nil
    ) {
        self.title = name
        self.endDate = endDate
        self.status = status
        self.project = project
        self.descriptionEvent = descriptionEvent
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

// MARK: - Extensions
extension Project {
    var allEventDocuments: [UploadedDocument] {
        events.flatMap { $0.documents }
    }
}
