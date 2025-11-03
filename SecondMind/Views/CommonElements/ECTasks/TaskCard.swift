import SwiftUI

struct TasksElementsListView<ViewModel: BaseTaskViewModel>: View {
    @ObservedObject var modelView: ViewModel
    @Environment(\.modelContext) var context
    @EnvironmentObject var utilFunctions: generalFunctions
    var accentColor: Color = .taskButtonColor
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if modelView.selectedTab == 0 {
                    Text("Sin fecha")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else if modelView.selectedTab == 1 {
                    Text(utilFunctions.formattedDate(modelView.selectedData))
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else {
                    Text("Tareas finalizadas")
                        .foregroundColor(.primary)
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
            } else if modelView.readyToShowTasks {
                if modelView.selectedTab == 2 {
                EndTaskList(viewModel: modelView)
                } else {
                    TaskListToDoView(modelView: modelView)
                }
            }
        }
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            modelView.setContext(context)
            modelView.loadTasks()
        }
    }




}
