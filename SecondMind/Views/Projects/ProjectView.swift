//
//  Project.swift
//  SecondMind
//
//  Created by Jorge Cortés on 17/6/25.
//

import SwiftUI


struct ProjectView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColorTemplate()
                VStack(alignment: .leading, spacing: 0) {
                    Header()
                        .frame(height: 40)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                    if hSizeClass == .regular {
                        ProjectMark()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ProjectMark()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .ignoresSafeArea(edges: .bottom) // igual que en EventsView
            }
        }
    }
}
