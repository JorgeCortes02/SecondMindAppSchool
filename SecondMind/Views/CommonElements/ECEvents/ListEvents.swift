//
//  listEvents.swift
//  SecondMind
//
//  Created by Jorge Cortés on 3/11/25.
//

import SwiftUI

struct EventGridOrListContainer<VM: BaseEventViewModel>: View {
    @ObservedObject var modelView: VM
    let accentColor: Color
    let isIpad: Bool
    @EnvironmentObject var utilFunctions: generalFunctions
    
    var body: some View {
        Group {
            if modelView.events.isEmpty {
                EmptyList(color: accentColor, textIcon: "calendar.badge.exclamationmark")
                    .padding(.top, 12)
            } else {
                if isIpad {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(modelView.events, id: \.id) { event in
                            EventCardExpanded(event: event, accentColor: accentColor)
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(modelView.events, id: \.id) { event in
                            NavigationLink(destination: EventDetall(editableEvent: event)) {
                                EventListItem(event: event, accentColor: accentColor)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
