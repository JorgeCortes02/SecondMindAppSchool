//
//  TaskListToDo.swift
//  SecondMind
//
//  Created by Jorge Cortés on 2/11/25.
//

import SwiftUI

struct TaskListToDoView<ViewModel: BaseTaskViewModel>: View {
    @ObservedObject var modelView: ViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
     var accentColor = Color.taskButtonColor
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(modelView.listTask, id: \.id) { task in
                NavigationLink(destination: TaskDetall(editableTask: task)) {
                    HStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                        
                        Text(task.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        if let due = task.endDate {
                            Label {
                                Text(utilFunctions.extractHour(due))
                            } icon: {
                                Image(systemName: "clock")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(accentColor.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            modelView.markAsCompleted(task)
                        }) {
                            Image(systemName: "circle")
                                .font(.system(size: 21))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.vertical, 8)
        .animation(.easeOut(duration: 0.35), value: modelView.listTask)
    }
}
