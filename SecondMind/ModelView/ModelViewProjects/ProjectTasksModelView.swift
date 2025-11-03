//
//  EventMarkProjectDetallModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 19/9/25.
//

import Foundation
import SwiftData
import SwiftUI

public class TaskMarkProjectDetallModelView: ObservableObject {
    
    @Published var taskList: [TaskItem] = []
    @Published var listTaskCalendarIpad: [TaskItem] = []
    @Published var selectedTab: Int = 0
    @Published var readyToShowTasks: Bool = false
    @Published var selectedData: Date = Date()
    @Published var showCal: Bool = false
    @Published var showAddTaskView: Bool = false
    
    private var project: Project?
    private var context: ModelContext?
    
    init(context: ModelContext? = nil, project: Project? = nil) {
        self.context = context
        self.project = project
    }
    
    func setParameters(context: ModelContext, project: Project) {
        self.context = context
        self.project = project
    }
    
    func extractDayTasks(date: Date) -> [TaskItem] {
        guard let project else { return [] }
        return project.tasks.filter { task in
            if let endDate = task.endDate {
                return Calendar.current.isDate(endDate, inSameDayAs: date) && task.status == .on
            }
            return false
        }
    }
    
    func extractNoDateTasks() -> [TaskItem] {
        guard let project else { return []}
        
        return project.tasks.filter { $0.endDate == nil && $0.status == .on }
    }
    
    func extractOffTasks() -> [TaskItem] {
        guard let project else { return [] }
        return project.tasks.filter { $0.status == .off }
    }
    
    func loadEvents() {
        switch selectedTab {
        case 0:
            taskList = extractNoDateTasks()
            listTaskCalendarIpad = extractDayTasks(date: selectedData)
        case 1:
        
                taskList = extractDayTasks(date: selectedData)
            
        case 2:
            taskList = extractOffTasks()
        default:
            break
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.readyToShowTasks = true
            }
        }
    }
}

extension TaskMarkProjectDetallModelView: BaseTaskViewModel {

    var listTask: [TaskItem] {
        get { taskList }
        set { taskList = newValue }
    }

    func setContext(_ context: ModelContext) {
        self.context = context
    }

    func loadTasks() {
       
        loadEvents()
    }

    func markAsCompleted(_ task: TaskItem) {
        guard let context else { return }
        task.status = .off
        task.completeDate = Date()
        do {
            try context.save()
            Task { await SyncManagerUpload.shared.uploadTask(task: task) }
            taskList.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al guardar tarea completada: \(error)")
        }
    }

    func deleteTask(_ task: TaskItem) {
        guard let context else { return }
        do {
            try context.delete(task)
            try context.save()
            Task { await SyncManagerUpload.shared.deleteTask(task: task) }
            taskList.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al borrar tarea: \(error)")
        }
    }
}
