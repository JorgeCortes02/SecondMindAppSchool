import Foundation
import SwiftUI
import SwiftData

protocol BaseTaskViewModel: ObservableObject {
    // MARK: - Published properties
    var listTask: [TaskItem] { get set }
    var readyToShowTasks: Bool { get set }
    var selectedTab: Int { get set }
    var selectedData: Date { get set }
    var showCal: Bool { get set }
    var showAddTaskView: Bool { get set }
    var listTaskCalendarIpad: [TaskItem] { get set }
    // MARK: - Context management
    func setContext(_ context: ModelContext)
    
    // MARK: - Load and state logic
    func loadTasks()
    func markAsCompleted(_ task: TaskItem)
    func deleteTask(_ task: TaskItem)
}
