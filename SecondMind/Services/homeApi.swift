
//  homeApi.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.
//
import SwiftUI
import SwiftData
struct HomeApi {
   
    static func fetchTodayTasks(context : ModelContext) -> [TaskItem] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicate = #Predicate<TaskItem> {
            if let due = $0.endDate {
                return due >= startOfToday && due < endOfToday
            } else {
                return false
            }
        }
        
        let descriptorTask = FetchDescriptor<TaskItem>(predicate: predicate)
      
        do {
            let tareas = try context.fetch(descriptorTask)
           NSLog("Tereaaas \(tareas.count)")
            return tareas
                .filter { $0.status == ActivityStatus.on }
                .sorted {
                    guard let d1 = $0.endDate, let d2 = $1.endDate else {
                        // Opcional: puedes decidir qué hacer si hay nils
                        return $0.endDate != nil
                    }
                    return d1 < d2
                }
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
    }
    
    static func fetchTodayEvents(context : ModelContext) -> [Event] {
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicateEvent = #Predicate<Event> {
            $0.endDate >= startOfToday && $0.endDate < endOfToday
        }
        
        let descriptorEvent = FetchDescriptor<Event>(predicate: predicateEvent)
        
        do {
            let eventos = try context.fetch(descriptorEvent)
          
            return eventos.filter{
                $0.status == .on
            }
            
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
    }
    
    
    static func fetchProjectEvents(context : ModelContext) -> [Event] {
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let predicateEvent = #Predicate<Event> {
            $0.endDate >= startOfToday && $0.endDate < endOfToday
        }
        
        let descriptorEvent = FetchDescriptor<Event>(predicate: predicateEvent)
        
        do {
            let eventos = try context.fetch(descriptorEvent)
          
            return eventos.filter{
                $0.status == .on
            }
            
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
    }
    
    
    
    static func fetchDateTasks(date: Date,  context : ModelContext) -> [TaskItem] {
        
       
        let predicate = #Predicate<TaskItem> {
            $0.endDate != nil
        }
        let descriptorTask = FetchDescriptor<TaskItem>(predicate: predicate)
      
        do {
            let allTasks = try context.fetch(descriptorTask)
                    // Filtrado por día después del fetch
                    return allTasks.filter {
                        if let due = $0.endDate {
                               return $0.status == .on &&
                                      Calendar.current.isDate(due, inSameDayAs: date)
                           }
                           return false
                    }
            
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
    }
    static func fetchNoDateTasks(context: ModelContext) -> [TaskItem] {
        let predicate = #Predicate<TaskItem> {
            $0.endDate == nil
        }
        
        // 👇 Orden por createDate descendente
        let sort = [SortDescriptor(\TaskItem.createDate, order: .reverse)]
        
        let descriptorTask = FetchDescriptor<TaskItem>(
            predicate: predicate,
            sortBy: sort
        )
        
        do {
            let allTasks = try context.fetch(descriptorTask)
            return allTasks.filter { $0.status == .on }
        } catch {
            print("❌ Error al hacer fetch de tareas sin fecha: \(error)")
            return []
        }
    }
    
    static func downdloadEventsFrom(context : ModelContext) -> [Event] {
        
   
        do{
            
            let eventsOn = try context.fetch(FetchDescriptor<Event>())
            return eventsOn.filter{$0.status == .on}
        }
        catch {
            print("❌ Error al hacer fetch de Eventos: \(error)")
            return []
        }
        
    }
    
    static func downdloadEventsFromProject(project: Project, context : ModelContext) -> [Event] {
        
   
        do{
            
            let eventsOn = try context.fetch(FetchDescriptor<Event>())
            return eventsOn.filter{$0.status == .on && $0.project == project}
        }
        catch {
            print("❌ Error al hacer fetch de Eventos: \(error)")
            return []
        }
        
    }
    
    
    static func downdloadProjectsFrom(context : ModelContext) -> [Project] {
        
       
        
        do{
            let allProjects = try context.fetch(FetchDescriptor<Project>())
            return allProjects.filter { $0.status == .on }
        }
        catch {
            print("❌ Error al hacer fetch de projectos: \(error)")
            return []
        }
        
    }
    
    
    static func loadTasksEnd(context: ModelContext) -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate {
                $0.completeDate != nil
            }
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error al cargar tareas:", error)
            return []
        }
    }
    
    static func downdloadEventsDate(date : Date, context : ModelContext) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Event> {
            $0.endDate >= startOfDay && $0.endDate < endOfDay
        }
        
        
        
        let descriptorEvent = FetchDescriptor<Event>(predicate: predicate)
        
        do {
            let events = try context.fetch(descriptorEvent)
            
            return events
            
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
        
        
    }
    
    static func downdloadProjectEventsDate(date : Date, context : ModelContext, project: Project) -> [Event] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Event> {
            $0.endDate >= startOfDay && $0.endDate < endOfDay
        }
        
        
        
        let descriptorEvent = FetchDescriptor<Event>(predicate: predicate)
        
        do {
            let events = try context.fetch(descriptorEvent)
            
            
            return events.filter { $0.project == project }
            
            
        } catch {
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return []
        }
        
        
    }
    
    static func loadLastDeleteTaskDate(context : ModelContext) -> lastDeleteTask?{
        
        do{
            
            let results = try context.fetch(FetchDescriptor<lastDeleteTask>())
            return results
                .filter { $0.date != nil }
                .sorted { $0.date! > $1.date! }
                .first

        }catch{
            print("❌ Error al hacer fetch de tareas de hoy: \(error)")
            return nil
            
        }
        
    }
    
    static func eventsLastWeek (context : ModelContext) -> [Event] {
        
        
        let actualDate = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: actualDate)!
        
        let predicate = #Predicate<Event> {
            $0.endDate >= sevenDaysAgo
        }
        
        do{
            
            let results =  try context.fetch(FetchDescriptor<Event>(predicate: predicate))
            return results.filter{$0.status == .off}
        }catch{
            print("❌ Error al hacer fetch de eventos  pasados: \(error)")
            return []
        }
        
        
        
    }
    
    
    static func downloadOnProjects(context: ModelContext) -> [Project] {
        
    
        
        
        do{
            
            let projectsOn =  try context.fetch(FetchDescriptor<Project>())
        
            return projectsOn.filter{
                $0.status.rawValue == "on"
            }.sorted{$0.lastOpenedDate < $1.lastOpenedDate}
            
        }catch{
            
            print("❌ Error al hacer fetch de proyectos activos: \(error)")
            return []
        }
        
    }
    
    static func downloadOffProjects(context: ModelContext) -> [Project] {
        
       
        do{
            
            let eventsOff =  try context.fetch(FetchDescriptor<Project>())
            return eventsOff.filter{
                $0.status.rawValue == "off"
            }
            
        }catch{
            
            print("❌ Error al hacer fetch de proyectos activos: \(error)")
            return []
        }
        
    }
    
    

    static func downloadNotes(context: ModelContext) -> [NoteItem] {
          do {
              let notes = try context.fetch(FetchDescriptor<NoteItem>())
              return  notes.filter { !$0.isArchived }
          } catch {
              print("❌ Error cargando notas: \(error)")
              return []
          }
      }
        
        
    
    
    
    
    
    }
