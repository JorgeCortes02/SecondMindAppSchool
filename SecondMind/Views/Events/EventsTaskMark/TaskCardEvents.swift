//
//  TaskCardEvents.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/11/25.
//

import SwiftUI
struct TasksElementsListViewEvents<ViewModel: BaseTaskViewModel>: View {
    @ObservedObject var modelView: ViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    var accentColor: Color = .taskButtonColor
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if modelView.selectedTab == 0 {
                            Text(utilFunctions.formattedDate(modelView.selectedData))
                                .foregroundColor(.taskButtonColor)
                                .font(.title2.weight(.bold))
                        }  else {
                            Text("Tareas finalizadas")
                                .foregroundColor(.taskButtonColor)
                                .font(.title2.weight(.bold))
                        }
                        
                        Spacer()
                        Text("\(modelView.listTask.count)")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Rectangle()
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 1)
                    
                    if modelView.listTask.isEmpty {
                        EmptyList(color: accentColor, textIcon: "checkmark.seal.text.page")
                            .frame(maxHeight: .infinity)
                    } else if modelView.readyToShowTasks {
                        VStack(alignment: .leading, spacing: 0) {
                            if modelView.selectedTab == 1 {
                                EndTaskList(viewModel: modelView)
                            } else {
                                TaskListToDoView(modelView: modelView)
                            }
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.bottom, 80)
                    }
                }
                .frame(minHeight: geometry.size.height, alignment: .top)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
            }.clipShape(RoundedRectangle(cornerRadius: 36))
        }
    }
}
