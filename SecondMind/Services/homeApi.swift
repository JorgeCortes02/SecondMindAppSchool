//  homeApi.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.
//

import SwiftUI
import SwiftData

struct HomeApi {
    
   
    
    // MARK: - Recuperar token
    private func getToken() -> String? {
        guard let data = KeychainHelper.standard.read(service: "SecondMindUserId", account: "SecondMind") else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    private static var token: String { CurrentUser.token() }
    
    // MARK: - Today Tasks
    static func fetchTodayTasks(context: ModelContext) -> [TaskItem] {
        
       
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<TaskItem> { $0.token == token && $0.endDate != nil }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate)

        do {
            let tareas = try context.fetch(descriptor)
            return tareas
                .filter {
                    if let due = $0.endDate {
                        return $0.status == .on && due >= startOfToday && due < endOfToday
                    }
                    return false
                }
                .sorted {
                    guard let d1 = $0.endDate, let d2 = $1.endDate else { return $0.endDate != nil }
                    return d1 < d2
                }
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
    }

    // MARK: - Today Events
    static func fetchTodayEvents(context: ModelContext) -> [Event] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let eventos = try context.fetch(descriptor)
            return eventos.filter { $0.status == .on && $0.endDate >= startOfToday && $0.endDate < endOfToday }
        } catch {
            print("❌ Error al hacer fetch de eventos de hoy: \(error)")
            return []
        }
    }

    // MARK: - Project Events (Today)
    static func fetchProjectEvents(context: ModelContext) -> [Event] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let eventos = try context.fetch(descriptor)
            return eventos.filter { $0.status == .on && $0.endDate >= startOfToday && $0.endDate < endOfToday }
        } catch {
            print("❌ Error al hacer fetch de eventos del proyecto: \(error)")
            return []
        }
    }

    // MARK: - Tasks by Date
    static func fetchDateTasks(date: Date, context: ModelContext) -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { $0.token == token && $0.endDate != nil }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate)

        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter {
                if let due = $0.endDate {
                    return $0.status == .on && Calendar.current.isDate(due, inSameDayAs: date)
                }
                return false
            }
        } catch {
            print("❌ Error al hacer fetch de tareas de un día: \(error)")
            return []
        }
    }

    // MARK: - Tasks with no date
    static func fetchNoDateTasks(context: ModelContext) -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { $0.token == token && $0.endDate == nil }
        let sort = [SortDescriptor(\TaskItem.createDate, order: .reverse)]
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate, sortBy: sort)

        do {
            let allTasks = try context.fetch(descriptor)
            return allTasks.filter { $0.status == .on }
        } catch {
            print("❌ Error al hacer fetch de tareas sin fecha: \(error)")
            return []
        }
    }

    // MARK: - Events
    static func downdloadEventsFrom(context: ModelContext) -> [Event] {
        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let eventsOn = try context.fetch(descriptor)
            return eventsOn.filter { $0.status == .on }
        } catch {
            print("❌ Error al hacer fetch de Eventos: \(error)")
            return []
        }
    }

    static func downdloadEventsFromProject(project: Project, context: ModelContext) -> [Event] {
        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            var eventsOn = try context.fetch(descriptor)
            eventsOn = eventsOn.filter { $0.status == .on && $0.project == project }
         
            return eventsOn
                
        } catch {
            print("❌ Error al hacer fetch de Eventos de proyecto: \(error)")
            return []
        }
    }

    static func downdloadProjectsFrom(context: ModelContext) -> [Project] {
        let predicate = #Predicate<Project> { $0.token == token }
        let descriptor = FetchDescriptor<Project>(predicate: predicate)

        do {
            let allProjects = try context.fetch(descriptor)
            return allProjects.filter { $0.status == .on }
        } catch {
            print("❌ Error al hacer fetch de projectos: \(error)")
            return []
        }
    }

    // MARK: - Completed Tasks
    static func loadTasksEnd(context: ModelContext) -> [TaskItem] {
        let predicate = #Predicate<TaskItem> { $0.token == token && $0.completeDate != nil }
        let descriptor = FetchDescriptor<TaskItem>(predicate: predicate)

        do {
            let tasks = try context.fetch(descriptor)
            return tasks.filter { $0.status == .off }
        } catch {
            print("Error al cargar tareas:", error)
            return []
        }
    }

    // MARK: - Events by Date
    static func downdloadEventsDate(date: Date, context: ModelContext) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let events = try context.fetch(descriptor)
            return events.filter { $0.endDate >= startOfDay && $0.endDate < endOfDay && $0.status == .on}
        } catch {
            print("❌ Error al hacer fetch de eventos del día: \(error)")
            return []
        }
    }

    static func downdloadProjectEventsDate(date: Date, context: ModelContext, project: Project) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let events = try context.fetch(descriptor)
            return events.filter { $0.project == project && $0.endDate >= startOfDay && $0.endDate < endOfDay }
        } catch {
            print("❌ Error al hacer fetch de eventos del proyecto por día: \(error)")
            return []
        }
    }

    // MARK: - LastDeleteTask
    static func loadLastDeleteTaskDate(context: ModelContext) -> LastDeleteTask? {
        let predicate = #Predicate<LastDeleteTask> { $0.token == token }
        let descriptor = FetchDescriptor<LastDeleteTask>(predicate: predicate)

        do {
            let results = try context.fetch(descriptor)
            return results.filter { $0.date != nil }.sorted { $0.date! > $1.date! }.first
        } catch {
            print("❌ Error al cargar LastDeleteTask: \(error)")
            return nil
        }
    }

    // MARK: - Events last week
    static func eventsLastWeek(context: ModelContext) -> [Event] {
        let actualDate = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: actualDate)!

        let predicate = #Predicate<Event> { $0.token == token }
        let descriptor = FetchDescriptor<Event>(predicate: predicate)

        do {
            let results = try context.fetch(descriptor)
            return results.filter { $0.status == .off && $0.endDate >= sevenDaysAgo }
        } catch {
            print("❌ Error al hacer fetch de eventos pasados: \(error)")
            return []
        }
    }

    // MARK: - Projects (On/Off)
    static func downloadOnProjects(context: ModelContext) -> [Project] {
        let predicate = #Predicate<Project> { $0.token == token }
        let descriptor = FetchDescriptor<Project>(predicate: predicate)

        do {
            let projectsOn = try context.fetch(descriptor)
            return projectsOn.filter { $0.status == .on }.sorted { $0.lastOpenedDate < $1.lastOpenedDate }
        } catch {
            print("❌ Error al hacer fetch de proyectos activos: \(error)")
            return []
        }
    }

    static func downloadOffProjects(context: ModelContext) -> [Project] {
        let predicate = #Predicate<Project> { $0.token == token }
        let descriptor = FetchDescriptor<Project>(predicate: predicate)

        do {
            let projectsOff = try context.fetch(descriptor)
            return projectsOff.filter { $0.status == .off }
        } catch {
            print("❌ Error al hacer fetch de proyectos inactivos: \(error)")
            return []
        }
    }

    // MARK: - Notes
    static func downloadActiveNotes(context: ModelContext) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            return notes.filter { !$0.isArchived }
        } catch {
            print("❌ Error cargando notas activas: \(error)")
            return []
        }
    }

    static func downloadArchivedNotes(context: ModelContext) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            return notes.filter { $0.isArchived }
        } catch {
            print("❌ Error cargando notas archivadas: \(error)")
            return []
        }
    }

    static func downloadFavoritesNotes(context: ModelContext) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            return notes.filter { !$0.isArchived && $0.isFavorite }
        } catch {
            print("❌ Error cargando notas favoritas: \(error)")
            return []
        }
    }

    // MARK: - Search Notes
    static func searchActiveNotes(context: ModelContext, query: String) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            let lowerQuery = query.lowercased()
            return notes.filter {
                !$0.isArchived && (
                    $0.title.lowercased().contains(lowerQuery) ||
                    ($0.content?.lowercased().contains(lowerQuery) ?? false)
                )
            }
        } catch {
            print("❌ Error buscando notas activas: \(error)")
            return []
        }
    }

    static func searchArchivedNotes(context: ModelContext, query: String) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            let lowerQuery = query.lowercased()
            return notes.filter {
                $0.isArchived && (
                    $0.title.lowercased().contains(lowerQuery) ||
                    ($0.content?.lowercased().contains(lowerQuery) ?? false)
                )
            }
        } catch {
            print("❌ Error buscando notas archivadas: \(error)")
            return []
        }
    }

    static func searchFavoritesNotes(context: ModelContext, query: String) -> [NoteItem] {
        let predicate = #Predicate<NoteItem> { $0.token == token }
        let descriptor = FetchDescriptor<NoteItem>(predicate: predicate)

        do {
            let notes = try context.fetch(descriptor)
            let lowerQuery = query.lowercased()
            return notes.filter {
                !$0.isArchived && $0.isFavorite && (
                    $0.title.lowercased().contains(lowerQuery) ||
                    ($0.content?.lowercased().contains(lowerQuery) ?? false)
                )
            }
        } catch {
            print("❌ Error buscando notas favoritas: \(error)")
            return []
        }
    }
    
    static func fetchProjectByExternalId(id: UUID, context: ModelContext) -> Project? {
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.externalId == id }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Error al obtener Project con externalId \(id): \(error)")
            return nil
        }
    }
    
    static func fetchEventByExternalId(id: UUID, context: ModelContext) -> Event? {
        let descriptor = FetchDescriptor<Event>(
            predicate: #Predicate { $0.externalId == id }
        )

        do {
            return try context.fetch(descriptor).first
        } catch {
            print("❌ Error al obtener Project con externalId \(id): \(error)")
            return nil
        }
    }
}
