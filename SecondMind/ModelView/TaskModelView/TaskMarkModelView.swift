//
//  TaskMarkModelView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 24/9/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    @Published var listTask: [TaskItem] = []
    @Published var readyToShowTasks: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var selectedTab: Int = 0   
    private var context: ModelContext?

    // Configurar contexto desde la vista
    func setContext(_ context: ModelContext) {
        self.context = context
    }

    // Cargar según pestaña
    func loadTasks(for tab: Int, utilFunctions: generalFunctions) {
        guard let context else { return }
        switch tab {
        case 0:
            listTask = HomeApi.fetchNoDateTasks(context: context)
        case 1:
            listTask = HomeApi.fetchDateTasks(date: selectedDate, context: context)
        case 2:
            listTask = HomeApi.loadTasksEnd(context: context)
        default:
            listTask = []
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.readyToShowTasks = true
            }
        }
    }

    func markAsCompleted(_ task: TaskItem) {
        guard let context else { return }
        task.completeDate = Date()
        task.status = .off
        do {
            try context.save()
            Task{
                
                await SyncManagerUpload.shared.uploadTask(task: task)
                
            }
            listTask.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al guardar: \(error)")
        }
    }

    func deleteTask(_ task: TaskItem) {
        guard let context else { return }
        do {
            try context.delete(task)
            try context.save()
            Task{
               await SyncManagerUpload.shared.deleteTask(task: task)
            }
            listTask.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al borrar: \(error)")
        }
    }
}
