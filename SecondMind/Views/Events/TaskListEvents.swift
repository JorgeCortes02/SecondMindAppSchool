//
//  TaskListEvents.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/11/25.
//

import SwiftUI
import SwiftData

struct EventTaskList: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions

    @Bindable var editableEvent: Event

    @StateObject private var viewModel: EventTaskListViewModel

    init(event: Event) {
        self._editableEvent = Bindable(wrappedValue: event)
        _viewModel = StateObject(wrappedValue: EventTaskListViewModel(event: event))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Tareas del evento")
                    .font(.headline)
                    .foregroundColor(Color.taskButtonColor)
                Text("\(viewModel.filteredTasks.count)").bold()
                Spacer()
              
                NavigationLink(destination: EventTaskView(event: viewModel.editableEvent)) {
                    HStack(spacing: 4) {
                        Text("Ver más")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.taskButtonColor)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color.taskButtonColor)
                    }
                }
            }

            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)

            // Contenido
            if viewModel.filteredTasks.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.text.page")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 90)
                        .foregroundColor(Color.taskButtonColor.opacity(0.7))

                    Text("No hay tareas disponibles.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, minHeight: 150)
                .padding(20)
            } else if viewModel.filteredTasks.count == 1 {
                ForEach(viewModel.filteredTasks.prefix(1)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                }
            } else {
                ForEach(viewModel.filteredTasks.prefix(2)) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        taskRow(task: task)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBG)
        .cornerRadius(20)
        .onAppear {
            viewModel.updateDependencies(context: context, utilFunctions: utilFunctions)
        }
    }

    // MARK: - Fila
    private func taskRow(task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checklist")
                .font(.system(size: 22))
                .foregroundColor(Color.taskButtonColor)

            Text(task.title)
                .font(.system(size: 17))
                .foregroundColor(.primary)

            Spacer()

            Button {
                viewModel.deleteTask(task)
            } label: {
                Image(systemName: "circle")
                    .font(.system(size: 21))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .modifier(TaskCardModifier())
    }
}
