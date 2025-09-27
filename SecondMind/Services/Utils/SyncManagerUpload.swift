import Foundation
import SwiftData

@MainActor
class SyncManagerUpload {
    static let shared = SyncManagerUpload()
    
    private let tokenKey = "SecondMindAuthToken"
    
    // MARK: - Recuperar token
    private func getToken() -> String? {
        guard let data = KeychainHelper.standard.read(service: tokenKey, account: "SecondMind") else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    // ============================================================
    // MARK: - Projects
    // ============================================================
    func uploadProjects(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let projects = try context.fetch(FetchDescriptor<Project>())
            for p in projects {
                let extId = p.externalId ?? UUID()
                _ = try await APIClient.shared.createOrUpdateProject(
                    externalId: extId,
                    title: p.title,
                    description: p.descriptionProject,
                    status: p.status.rawValue,
                    token: token
                )
                print("✅ Proyecto subido:", p.title)
            }
        } catch {
            print("❌ Upload Projects failed:", error)
        }
    }
    
    func uploadProject(project: Project) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let extId = project.externalId ?? UUID()
            _ = try await APIClient.shared.createOrUpdateProject(
                externalId: extId,
                title: project.title,
                description: project.descriptionProject,
                status: project.status.rawValue,
                token: token
            )
            print("✅ Proyecto subido correctamente:", project.title)
        } catch {
            print("❌ Upload Project failed:", error)
        }
    }
    
    // ============================================================
    // MARK: - Events
    // ============================================================
    func uploadEvents(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let events = try context.fetch(FetchDescriptor<Event>())
            for e in events {
                let extId = e.externalId ?? UUID()
                _ = try await APIClient.shared.createOrUpdateEvent(
                    externalId: extId,
                    title: e.title,
                    projectExternalId: e.project?.externalId,
                    endDate: e.endDate,
                    description: e.descriptionEvent,
                    address: e.address,
                    latitude: e.latitude,
                    longitude: e.longitude,
                    status: e.status.rawValue,
                    token: token
                )
                print("✅ Evento subido:", e.title)
            }
        } catch {
            print("❌ Upload Events failed:", error)
        }
    }
    
    func uploadEvent(event: Event) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let extId = event.externalId ?? UUID()
            _ = try await APIClient.shared.createOrUpdateEvent(
                externalId: extId,
                title: event.title,
                projectExternalId: event.project?.externalId,
                endDate: event.endDate,
                description: event.descriptionEvent,
                address: event.address,
                latitude: event.latitude,
                longitude: event.longitude,
                status: event.status.rawValue,
                token: token
            )
            print("✅ Evento subido correctamente:", event.title)
        } catch {
            print("❌ Upload Event failed:", error)
        }
    }
    
    // ============================================================
    // MARK: - Tasks
    // ============================================================
    func uploadTasks(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let tasks = try context.fetch(FetchDescriptor<TaskItem>())
            for t in tasks {
                let extId = t.externalId ?? UUID()
                _ = try await APIClient.shared.createOrUpdateTask(
                    externalId: extId,
                    title: t.title,
                    description: t.descriptionTask,
                    projectExternalId: t.project?.externalId,
                    eventExternalId: t.event?.externalId,
                    endDate: t.endDate,
                    completeDate: t.completeDate,
                    status: t.status.rawValue,
                    token: token
                )
                print("✅ Task subida:", t.title)
            }
        } catch {
            print("❌ Upload Tasks failed:", error)
        }
    }
    // MARK: - Subir una única Task
    func uploadTask(task: TaskItem) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        
        do {
            let extId = task.externalId ?? UUID()
            _ = try await APIClient.shared.createOrUpdateTask(
                externalId: extId,
                title: task.title,
                description: task.descriptionTask,
                projectExternalId: task.project?.externalId,
                eventExternalId: task.event?.externalId,
                endDate: task.endDate,
                completeDate: task.completeDate,
                status: task.status.rawValue,
                token: token
            )
            
            print("✅ Task subida correctamente:", task.title)
        } catch {
            print("❌ Upload Task failed:", error)
        }
    }
    
    // ============================================================
    // MARK: - Notes
    // ============================================================
    func uploadNotes(context: ModelContext) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let notes = try context.fetch(FetchDescriptor<NoteItem>())
            for n in notes {
                let extId = n.externalId ?? UUID()
                _ = try await APIClient.shared.createOrUpdateNote(
                    externalId: extId,
                    title: n.title,
                    content: n.content ?? "",
                    projectExternalId: n.project?.externalId,
                    eventExternalId: n.event?.externalId,
                    createdAt: n.createdAt,
                    updatedAt: n.updatedAt,
                    isFavorite: n.isFavorite,
                    isArchived: n.isArchived,
                    token: token
                )
                print("✅ Nota subida:", n.title)
            }
        } catch {
            print("❌ Upload Notes failed:", error)
        }
    }
    
    func uploadNote(note: NoteItem) async {
        guard let token = getToken() else {
            print("❌ No hay token en Keychain")
            return
        }
        do {
            let extId = note.externalId ?? UUID()
            _ = try await APIClient.shared.createOrUpdateNote(
                externalId: extId,
                title: note.title,
                content: note.content ?? "",
                projectExternalId: note.project?.externalId,
                eventExternalId: note.event?.externalId,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isFavorite: note.isFavorite,
                isArchived: note.isArchived,
                token: token
            )
            print("✅ Nota subida correctamente:", note.title)
        } catch {
            print("❌ Upload Note failed:", error)
        }
    }
    
    
    // ============================================================
       func deleteProject(project: Project) async {
           guard let token = getToken(), let extId = project.externalId else {
               print("❌ Falta token o externalId en Project")
               return
           }
           do {
               try await APIClient.shared.deleteProject(externalId: extId, token: token)
               print("🗑️ Proyecto eliminado en server:", project.title)
           } catch {
               print("❌ Error al eliminar Project:", error)
           }
       }
       
       // ============================================================
       // MARK: - Events
       // ============================================================
       func deleteEvent(event: Event) async {
           guard let token = getToken(), let extId = event.externalId else {
               print("❌ Falta token o externalId en Event")
               return
           }
           do {
               try await APIClient.shared.deleteEvent(externalId: extId, token: token)
               print("🗑️ Evento eliminado en server:", event.title)
           } catch {
               print("❌ Error al eliminar Event:", error)
           }
       }
       
       // ============================================================
       // MARK: - Tasks
       // ============================================================
       func deleteTask(task: TaskItem) async {
           guard let token = getToken(), let extId = task.externalId else {
               print("❌ Falta token o externalId en Task")
               return
           }
           do {
               try await APIClient.shared.deleteTask(externalId: extId, token: token)
               print("🗑️ Task eliminada en server:", task.title)
           } catch {
               print("❌ Error al eliminar Task:", error)
           }
       }
       
       // ============================================================
       // MARK: - Notes
       // ============================================================
       func deleteNote(note: NoteItem) async {
           guard let token = getToken(), let extId = note.externalId else {
               print("❌ Falta token o externalId en Note")
               return
           }
           do {
               try await APIClient.shared.deleteNote(externalId: extId, token: token)
               print("🗑️ Nota eliminada en server:", note.title)
           } catch {
               print("❌ Error al eliminar Note:", error)
           }
       }
       
       // ============================================================
       // MARK: - Documents
       // ============================================================
       func deleteDocument(doc: UploadedDocument) async {
           guard let token = getToken(), let extId = doc.externalId else {
               print("❌ Falta token o externalId en Document")
               return
           }
           do {
               try await APIClient.shared.deleteDocument(externalId: extId, token: token)
               print("🗑️ Documento eliminado en server:", doc.title)
           } catch {
               print("❌ Error al eliminar Document:", error)
           }
       }
}
