//
//  ProjectListView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.

import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(projects) { project in
                    ProjectCardView(project: project)
                     
                }.frame(height: 120)
            }
            .padding(.horizontal, 16)
        }
    }
}
