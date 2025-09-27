import Foundation

// ============================================================
// MARK: - Project DTO
// ============================================================
struct ProjectDTO: Codable {
    let external_id: String
    let title: String
    let description_project: String?
    let status: String
    let last_opened_date: Date?
}

// ============================================================
// MARK: - Event DTO
// ============================================================
struct EventDTO: Codable {
    let external_id: String
    let title: String
    let end_date: Date
    let status: String
    let description_event: String?
    let project_external_id: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?
}

// ============================================================
// MARK: - Task DTO
// ============================================================
struct TaskItemDTO: Codable {
    let external_id: String
    let title: String
    let end_date: Date?
    let complete_date: Date?
    let status: String
    let description_task: String?
    let project_external_id: String?
    let event_external_id: String?
}

// ============================================================
// MARK: - Note DTO
// ============================================================
struct NoteItemDTO: Codable {
    let external_id: String
    let title: String
    let content: String?
    let project_external_id: String?
    let event_external_id: String?
    let created_at: Date
    let updated_at: Date
    let is_favorite: Bool
    let is_archived: Bool
}

// ============================================================
// MARK: - Document DTO
// ============================================================
struct UploadedDocumentDTO: Codable {
    let external_id: String
    let title: String
    let local_url: String
    let event_external_id: String?
    let upload_date: Date?
}

// ============================================================
// MARK: - LastDeleteTask DTO
// ============================================================
struct LastDeleteTaskDTO: Codable {
    let date: Date
}
