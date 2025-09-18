//
//  JSONConversionModels.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/9/25.
//

import Foundation

// MARK: - DTOs (Modelos para la API)
struct ProjectDTO: Codable, Identifiable {
    let id: Int
    var title: String
    var description_project: String?
    var status: String
    var end_date: Date?
    var last_opened_date: Date?
}

struct EventDTO: Codable, Identifiable {
    let id: Int
    var title: String
    var description_event: String?
    var status: String
    var end_date: Date
    var project_id: Int?
}

struct TaskItemDTO: Codable, Identifiable {
    let id: Int
    var title: String
    var description_task: String?
    var status: String
    var end_date: Date?
    var complete_date: Date?
    var project_id: Int?
    var event_id: Int?
}

struct NoteDTO: Codable, Identifiable {
    let id: Int
    var title: String
    var content: String
    var event_id: Int
}

struct UploadedDocumentDTO: Codable, Identifiable {
    let id: Int
    var title: String
    var local_url: String
    var upload_date: Date
    var event_id: Int?
}

struct LastDeleteTaskDTO: Codable, Identifiable {
    let id: Int
    var date: Date?
}
