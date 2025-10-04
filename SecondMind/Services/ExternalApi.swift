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
        
        // 👇 Base URL principal
        private let baseURL = URL(string: "https://secondmind-h6hv.onrender.com")!
        
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
        
        // ============================================================
        // MARK: - Helpers genéricos
        // ============================================================
        
    private func get<T: Decodable>(_ path: String, token: String? = nil) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, _) = try await URLSession.shared.data(for: req)

        // 👇 Depuración: imprime la respuesta cruda
        if let raw = String(data: data, encoding: .utf8) {
            print("📩 GET \(path) →", raw)
        }

        return try decoder.decode(T.self, from: data)
    }
        
        // MARK: - Generic POST/PUT
        private func send<T: Decodable, B: Encodable>(
            _ path: String,
            method: String,
            body: B,
            token: String? = nil
        ) async throws -> T {
            let url = baseURL.appendingPathComponent(path)
            var req = URLRequest(url: url)
            req.httpMethod = method
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let token = token {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            req.httpBody = try encoder.encode(body)
            
            let (data, response) = try await URLSession.shared.data(for: req)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NSError(
                    domain: "APIClient",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Request failed with status \(httpResponse.statusCode)"]
                )
            }
            
            // ✅ si se espera EmptyResponse y no hay body, devolver vacío
            if T.self == EmptyResponse.self, data.isEmpty {
                return EmptyResponse() as! T
            }
            
            return try decoder.decode(T.self, from: data)
        }
        
        // MARK: - Generic DELETE
        private func deleteRequest(_ path: String, token: String? = nil) async throws {
            let url = baseURL.appendingPathComponent(path)
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            if let token = token {
                req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let (_, response) = try await URLSession.shared.data(for: req)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
        }
        
        struct EmptyResponse: Decodable {}
        
        // ============================================================
        // MARK: - Auth / User
        // ============================================================
        struct UserResponse: Codable {
            let id: Int
            let name: String
            let email: String
        }
        
        func updateProfile(token: String, name: String, email: String?) async throws {
            struct Body: Encodable { let name: String; let email: String? }
            let _: EmptyResponse = try await send(
                "auth/update-profile",
                method: "PUT",
                body: Body(name: name, email: email),
                token: token
            )
        }

        func changePassword(token: String, currentPassword: String, newPassword: String) async throws {
            struct Body: Encodable { let currentPassword: String; let newPassword: String }
            let _: EmptyResponse = try await send(
                "auth/change-password",
                method: "PUT",
                body: Body(currentPassword: currentPassword, newPassword: newPassword),
                token: token
            )
        }
        
        // ============================================================
        // MARK: - Projects
        // ============================================================
        func fetchProjects(token: String) async throws -> [ProjectDTO] {
            try await get("projects", token: token)
        }
        
        func createOrUpdateProject(
            externalId: UUID,
            title: String,
            description: String?,
            status: String = "on",
            token: String
        ) async throws {
            struct Body: Encodable {
                let external_id: UUID
                let title: String
                let description_project: String?
                let status: String
            }
            let _: EmptyResponse = try await send(
                "projects", method: "POST",
                body: Body(external_id: externalId, title: title, description_project: description, status: status),
                token: token
            )
        }
        
        func deleteProject(externalId: UUID, token: String) async throws {
            try await deleteRequest("projects/\(externalId.uuidString)", token: token)
        }
        
        // ============================================================
        // MARK: - Tasks
        // ============================================================
        func fetchTasks(token: String) async throws -> [TaskItemDTO] {
            try await get("tasks", token: token)
        }
        
        func createOrUpdateTask(
            externalId: UUID,
            title: String,
            description: String?,
            projectExternalId: UUID?,
            eventExternalId: UUID?,
            endDate: Date?,
            completeDate: Date? = nil,
            status: String = "on",
            token: String
        ) async throws {
            struct Body: Encodable {
                let external_id: UUID
                let title: String
                let description_task: String?
                let project_external_id: UUID?
                let event_external_id: UUID?
                let end_date: Date?
                let complete_date: Date?
                let status: String
            }
            let _: EmptyResponse = try await send(
                "tasks", method: "POST",
                body: Body(external_id: externalId, title: title, description_task: description, project_external_id: projectExternalId, event_external_id: eventExternalId, end_date: endDate, complete_date: completeDate, status: status),
                token: token
            )
        }
        
        func deleteTask(externalId: UUID, token: String) async throws {
            try await deleteRequest("tasks/\(externalId.uuidString)", token: token)
        }
        
        // ============================================================
        // MARK: - Events
        // ============================================================
        func fetchEvents(token: String) async throws -> [EventDTO] {
            try await get("events", token: token)
        }
        
        func createOrUpdateEvent(
            externalId: UUID,
            title: String,
            projectExternalId: UUID?,
            endDate: Date,
            description: String?,
            address: String?,
            latitude: Double?,
            longitude: Double?,
            status: String = "on",
            token: String
        ) async throws {
            struct Body: Encodable {
                let external_id: UUID
                let title: String
                let project_external_id: UUID?
                let end_date: Date
                let description_event: String?
                let address: String?
                let latitude: Double?
                let longitude: Double?
                let status: String
            }
            let _: EmptyResponse = try await send(
                "events", method: "POST",
                body: Body(external_id: externalId, title: title, project_external_id: projectExternalId, end_date: endDate, description_event: description, address: address, latitude: latitude, longitude: longitude, status: status),
                token: token
            )
        }
        
        func deleteEvent(externalId: UUID, token: String) async throws {
            try await deleteRequest("events/\(externalId.uuidString)", token: token)
        }
        
        // ============================================================
        // MARK: - Notes
        // ============================================================
        func fetchNotes(token: String) async throws -> [NoteItemDTO] {
            try await get("notes", token: token)
        }
        
        func createOrUpdateNote(
            externalId: UUID,
            title: String,
            content: String?,
            projectExternalId: UUID?,
            eventExternalId: UUID?,
            createdAt: Date,
            updatedAt: Date,
            isFavorite: Bool,
            isArchived: Bool,
            token: String
        ) async throws {
            struct Body: Encodable {
                let external_id: UUID
                let title: String
                let content: String?
                let project_external_id: UUID?
                let event_external_id: UUID?
                let created_at: Date
                let updated_at: Date
                let is_favorite: Bool
                let is_archived: Bool
            }
            let _: EmptyResponse = try await send(
                "notes", method: "POST",
                body: Body(external_id: externalId, title: title, content: content, project_external_id: projectExternalId, event_external_id: eventExternalId, created_at: createdAt, updated_at: updatedAt, is_favorite: isFavorite, is_archived: isArchived),
                token: token
            )
        }
        
        func deleteNote(externalId: UUID, token: String) async throws {
            try await deleteRequest("notes/\(externalId.uuidString)", token: token)
        }
        
        // ============================================================
        // MARK: - Documents
        // ============================================================
        func fetchDocuments(token: String) async throws -> [UploadedDocumentDTO] {
            try await get("documents", token: token)
        }
        
        func createOrUpdateDocument(
            externalId: UUID,
            title: String,
            localURL: String,
            eventExternalId: UUID?,
            token: String
        ) async throws {
            struct Body: Encodable {
                let external_id: UUID
                let title: String
                let local_url: String
                let event_external_id: UUID?
            }
            let _: EmptyResponse = try await send(
                "documents", method: "POST",
                body: Body(external_id: externalId, title: title, local_url: localURL, event_external_id: eventExternalId),
                token: token
            )
        }
        
        func deleteDocument(externalId: UUID, token: String) async throws {
            try await deleteRequest("documents/\(externalId.uuidString)", token: token)
        }
        
        // ============================================================
        // MARK: - LastDeleteTask
        // ============================================================
        func fetchLastDeleteTask(token: String) async throws -> LastDeleteTaskDTO? {
            try await get("tasks/lastdelete", token: token)
        }
        
        func saveLastDeleteTask(date: Date, token: String) async throws -> LastDeleteTaskDTO {
            struct Body: Encodable { let date: Date }
            return try await send("tasks/lastdelete", method: "POST", body: Body(date: date), token: token)
        }
        
        // ============================================================
        // MARK: - Reminder
        // ============================================================
        func sendReminder(email: String, event: Event, token: String) {
            guard let url = URL(string: "https://secondmind-h6hv.onrender.com/reminder/send") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let payload: [String: Any] = [
                "email": email,
                "event": [
                    "title": event.title,
                    "endDate": event.endDate.ISO8601Format(),
                    "address": event.address ?? "",
                    "descriptionEvent": event.descriptionEvent ?? ""
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Error en red:", error.localizedDescription)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 Status code:", httpResponse.statusCode)
                }

                if let data = data,
                   let body = String(data: data, encoding: .utf8) {
                    print("📩 Respuesta del servidor:", body)
                }
            }.resume()
        }
    // ============================================================
    // MARK: - DELETE ENDPOINTS
    // ============================================================

    /// 🔹 Método genérico para DELETE requests
    func delete(_ path: String, token: String? = nil) async throws {
        let url = baseURL.appendingPathComponent(path)
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        if let token = token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: req)
        
        if let httpResponse = response as? HTTPURLResponse {
            guard httpResponse.statusCode == 200 else {
                throw NSError(domain: "APIClient",
                              code: httpResponse.statusCode,
                              userInfo: [NSLocalizedDescriptionKey: "DELETE failed with status \(httpResponse.statusCode)"])
            }
        }
    }
        
      
    
}
