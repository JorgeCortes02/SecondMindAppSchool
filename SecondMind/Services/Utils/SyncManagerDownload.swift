import Foundation
import SwiftData

@MainActor
class SyncManagerDownload {
    static let shared = SyncManagerDownload()
    
    private let tokenKey = "SecondMindAuthToken"
    private var isSyncing = false
    
    /// Recupera el token del Keychain
    private func getToken() -> String? {
        guard let data = KeychainHelper.standard.read(service: tokenKey, account: "SecondMind") else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    private func getStableToken() -> String? {
        guard let data = KeychainHelper.standard.read(service: "SecondMindUserId", account: "SecondMind") else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    // ============================================================
    // MARK: - Entry point
    // ============================================================
    func syncAll(context: ModelContext) async {
        guard !isSyncing else {
            print("⏳ Sync ya en curso, ignoramos esta llamada")
            return
        }
        isSyncing = true
        defer { isSyncing = false }
        
        await syncProjects(context: context)
        await syncEvents(context: context)
        await syncTasks(context: context)
        await syncNotes(context: context)
        
        
        
    }
    // ============================================================
    // MARK: - Projects
    // ============================================================
    func syncProjects(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        guard let stableToken = getStableToken() else {
            print("❌ No hay token de usuario estable en Keychain")
            return
        }
        do {
            let dtos = try await APIClient.shared.fetchProjects(token: token)
            let existing = try context.fetch(FetchDescriptor<Project>())
            var map = [UUID: Project]()
            for item in existing { if let ext = item.externalId { map[ext] = item } }

            for dto in dtos {
                guard let extId = UUID(uuidString: dto.external_id) else { continue }

                let project: Project
                if let existing = map[extId] {
                    project = existing
                } else {
                    project = Project(title: dto.title)
                    context.insert(project)
                }

                project.externalId = extId
                project.title = dto.title
                project.descriptionProject = dto.description_project
                project.status = ActivityStatus(rawValue: dto.status) ?? .on
                project.lastOpenedDate = dto.last_opened_date ?? Date()
                project.token = stableToken   // ✅ token correcto

                print("📥 Guardado Project:", project.title, "token:", project.token, "ext:", extId)
            }

            try context.save()
            print("✅ Projects sincronizados:", dtos.count)
        } catch {
            print("❌ Sync Projects failed:", error)
        }
    }

    // ============================================================
    // MARK: - Events
    // ============================================================
    func syncEvents(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        guard let stableToken = getStableToken() else {
            print("❌ No hay token de usuario estable en Keychain")
            return
        }
        do {
            let dtos = try await APIClient.shared.fetchEvents(token: token)
            let existing = try context.fetch(FetchDescriptor<Event>())
            var map = [UUID: Event]()
            for item in existing { if let ext = item.externalId { map[ext] = item } }

            for dto in dtos {
                guard let extId = UUID(uuidString: dto.external_id) else { continue }

                let event: Event
                if let existing = map[extId] {
                    event = existing
                } else {
                    event = Event(title: dto.title, endDate: dto.end_date)
                    context.insert(event)
                }

                event.externalId = extId
                event.title = dto.title
                event.endDate = dto.end_date
                event.status = ActivityStatus(rawValue: dto.status) ?? .on
                event.descriptionEvent = dto.description_event
                event.address = dto.address
                event.latitude = dto.latitude
                event.longitude = dto.longitude
                event.token = stableToken   // ✅ token correcto

                print("📥 Guardado Event:", event.title, "token:", event.token, "ext:", extId)
            }

            try context.save()
            print("✅ Events sincronizados:", dtos.count)
        } catch {
            print("❌ Sync Events failed:", error)
        }
    }

    // ============================================================
    // MARK: - Tasks
    // ============================================================
    func syncTasks(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        guard let stableToken = getStableToken() else {
            print("❌ No hay token de usuario estable en Keychain")
            return
        }
        do {
            let dtos = try await APIClient.shared.fetchTasks(token: token)
            let existing = try context.fetch(FetchDescriptor<TaskItem>())
            var map = [UUID: TaskItem]()
            for item in existing { if let ext = item.externalId { map[ext] = item } }

            for dto in dtos {
                guard let extId = UUID(uuidString: dto.external_id) else { continue }

                let task: TaskItem
                if let existing = map[extId] {
                    task = existing
                } else {
                    task = TaskItem(title: dto.title)
                    context.insert(task)
                }

                task.externalId = extId
                task.title = dto.title
                task.endDate = dto.end_date
                task.completeDate = dto.complete_date
                task.status = ActivityStatus(rawValue: dto.status) ?? .on
                task.descriptionTask = dto.description_task
                task.token = stableToken   // ✅ token correcto

                print("📥 Guardada Task:", task.title, "token:", task.token, "ext:", extId)
            }

            try context.save()
            print("✅ Tasks sincronizadas:", dtos.count)
        } catch {
            print("❌ Sync Tasks failed:", error)
        }
    }

    // ============================================================
    // MARK: - Notes
    // ============================================================
    func syncNotes(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        guard let stableToken = getStableToken() else {
            print("❌ No hay token de usuario estable en Keychain")
            return
        }
        do {
            let dtos = try await APIClient.shared.fetchNotes(token: token)
            let existing = try context.fetch(FetchDescriptor<NoteItem>())
            var map = [UUID: NoteItem]()
            for item in existing { if let ext = item.externalId { map[ext] = item } }

            for dto in dtos {
                guard let extId = UUID(uuidString: dto.external_id) else { continue }

                let note: NoteItem
                if let existing = map[extId] {
                    note = existing
                } else {
                    note = NoteItem(title: dto.title, content: dto.content ?? "")
                    context.insert(note)
                }

                note.externalId = extId
                note.title = dto.title
                note.content = dto.content ?? ""
                note.createdAt = dto.created_at
                note.updatedAt = dto.updated_at
                note.isFavorite = dto.is_favorite
                note.isArchived = dto.is_archived
                note.token = stableToken   // ✅ token correcto

                print("📥 Guardada Note:", note.title, "token:", note.token, "ext:", extId)
            }

            try context.save()
            print("✅ Notes sincronizadas:", dtos.count)
        } catch {
            print("❌ Sync Notes failed:", error)
        }
    }
}
