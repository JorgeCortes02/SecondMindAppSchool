//
//  ExternalApi.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/9/25.
//

import Foundation


// MARK: - API Client
class APIClient {
    static let shared = APIClient()
    
    private let baseURL = URL(string: "https://secondmind-h6hv.onrender.com/auth")! // 👈 cambia por tu URL en Render
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    // MARK: - Generic GET
    private func get<T: Decodable>(_ path: String, token: String? = nil) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Generic POST/PUT
    private func send<T: Decodable, B: Encodable>(_ path: String, method: String, body: B, token: String? = nil) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        req.httpBody = try encoder.encode(body)
        let (data, _) = try await URLSession.shared.data(for: req)
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Generic DELETE
    private func delete(_ path: String, token: String? = nil) async throws {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        _ = try await URLSession.shared.data(for: req)
    }
    
    // ============================================================
    // MARK: - Auth / User
    // ============================================================
    struct UserResponse: Codable {
        let id: Int
        let name: String
        let email: String
    }
    
    struct UpdateProfileResponse: Codable {
        let message: String
        let user: UserResponse
    }
    
    struct ChangePasswordResponse: Codable {
        let message: String
    }
    
    /// 🔹 Actualizar perfil (nombre + email opcional)
    func updateProfile(token: String, name: String, email: String?) async throws -> UserResponse {
        struct Body: Encodable {
            let name: String
            let email: String?
        }
        let response: UpdateProfileResponse = try await send(
            "update-profile",
            method: "PUT",
            body: Body(name: name, email: email),
            token: token
        )
        return response.user
    }
    
    /// 🔹 Cambiar contraseña
    func changePassword(token: String, currentPassword: String, newPassword: String) async throws -> String {
        struct Body: Encodable {
            let currentPassword: String
            let newPassword: String
        }
        let response: ChangePasswordResponse = try await send(
            "change-password",
            method: "PUT",
            body: Body(currentPassword: currentPassword, newPassword: newPassword),
            token: token
        )
        return response.message
    }
    
    // ============================================================
    // MARK: - Projects
    // ============================================================
    func fetchProjects() async throws -> [ProjectDTO] {
        try await get("projects")
    }
    
    func fetchActiveProjects() async throws -> [ProjectDTO] {
        try await get("projects/active")
    }
    
    func fetchOffProjects() async throws -> [ProjectDTO] {
        try await get("projects/off")
    }
    
    func createProject(title: String, description: String?) async throws -> ProjectDTO {
        struct Body: Encodable { let title: String; let description_project: String? }
        return try await send("projects", method: "POST", body: Body(title: title, description_project: description))
    }
    
    func updateProject(id: Int, title: String, description: String?, status: String) async throws -> ProjectDTO {
        struct Body: Encodable { let title: String; let description_project: String?; let status: String }
        return try await send("projects/\(id)", method: "PUT", body: Body(title: title, description_project: description, status: status))
    }
    
    func deleteProject(id: Int) async throws {
        try await delete("projects/\(id)")
    }
    
    // ============================================================
    // MARK: - Tasks
    // ============================================================
    func fetchTasks() async throws -> [TaskItemDTO] {
        try await get("tasks")
    }
    
    func fetchTodayTasks() async throws -> [TaskItemDTO] {
        try await get("tasks/today")
    }
    
    func fetchTasksByDate(date: Date) async throws -> [TaskItemDTO] {
        let formatter = ISO8601DateFormatter()
        let dateStr = formatter.string(from: date)
        let urlStr = "tasks/bydate?date=\(dateStr.prefix(10))"
        return try await get(urlStr)
    }
    
    func fetchNoDateTasks() async throws -> [TaskItemDTO] {
        try await get("tasks/nodate")
    }
    
    func createTask(title: String, description: String?, projectId: Int?, eventId: Int?, endDate: Date?) async throws -> TaskItemDTO {
        struct Body: Encodable {
            let title: String
            let description_task: String?
            let project_id: Int?
            let event_id: Int?
            let end_date: Date?
        }
        return try await send("tasks", method: "POST", body: Body(title: title, description_task: description, project_id: projectId, event_id: eventId, end_date: endDate))
    }
    
    func deleteTask(id: Int) async throws {
        try await delete("tasks/\(id)")
    }
    
    // ============================================================
    // MARK: - Events
    // ============================================================
    func fetchEvents() async throws -> [EventDTO] {
        try await get("events")
    }
    
    func fetchTodayEvents() async throws -> [EventDTO] {
        try await get("events/today")
    }
    
    func fetchEventsByProject(projectId: Int) async throws -> [EventDTO] {
        try await get("events/byproject/\(projectId)")
    }
    
    func createEvent(title: String, projectId: Int?, endDate: Date, description: String?) async throws -> EventDTO {
        struct Body: Encodable {
            let title: String
            let project_id: Int?
            let end_date: Date
            let description_event: String?
        }
        return try await send("events", method: "POST", body: Body(title: title, project_id: projectId, end_date: endDate, description_event: description))
    }
    
    // ============================================================
    // MARK: - Notes
    // ============================================================
    func fetchNotes() async throws -> [NoteDTO] {
        try await get("notes")
    }
    
    func createNote(title: String, content: String, eventId: Int) async throws -> NoteDTO {
        struct Body: Encodable { let title: String; let content: String; let event_id: Int }
        return try await send("notes", method: "POST", body: Body(title: title, content: content, event_id: eventId))
    }
    
    func deleteNote(id: Int) async throws {
        try await delete("notes/\(id)")
    }
    
    // ============================================================
    // MARK: - Documents
    // ============================================================
    func fetchDocuments() async throws -> [UploadedDocumentDTO] {
        try await get("documents")
    }
    
    func createDocument(title: String, localURL: String, eventId: Int?) async throws -> UploadedDocumentDTO {
        struct Body: Encodable { let title: String; let local_url: String; let event_id: Int? }
        return try await send("documents", method: "POST", body: Body(title: title, local_url: localURL, event_id: eventId))
    }
    
    func deleteDocument(id: Int) async throws {
        try await delete("documents/\(id)")
    }
    
    // ============================================================
    // MARK: - LastDeleteTask
    // ============================================================
    func fetchLastDeleteTask() async throws -> UploadedDocumentDTO? {
        try await get("tasks/lastdelete")
    }
    
    func saveLastDeleteTask(date: Date) async throws -> LastDeleteTaskDTO {
        struct Body: Encodable { let date: Date }
        return try await send("tasks/lastdelete", method: "POST", body: Body(date: date))
    }
}
