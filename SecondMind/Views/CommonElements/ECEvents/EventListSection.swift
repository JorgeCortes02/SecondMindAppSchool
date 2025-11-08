//
//  EventListSection.swift
//  SecondMind
//
//  Created by Jorge Cortés on 3/11/25.
//



import SwiftUI

struct EventListSection<VM: BaseEventViewModel>: View {
    @ObservedObject var modelView: VM
    
    let title: String
    let accentColor: Color
    let selectedDate: Binding<Date>?
    let isDateFilterEnabled: Bool
    let isIpad: Bool
    
    @EnvironmentObject var utilFunctions: generalFunctions

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                    Spacer()
                    Text("\(modelView.events.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Rectangle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 1)
                
                if isDateFilterEnabled, let selectedDate {
                    datePickerSection(selectedDate: selectedDate)
                }

                if modelView.events.isEmpty {
                    emptyEventsList()
                } else {
                    if isIpad {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(modelView.events, id: \.id) { event in
                                EventCardExpanded(event: event, accentColor: accentColor)
                            }
                        }.padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(modelView.events, id: \.id) { event in
                                NavigationLink(destination: EventDetall(editableEvent: event)) {
                                    EventListItem(event: event, accentColor: accentColor)
                                }
                            }
                        }.padding(.bottom, 20)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .frame(maxWidth: isIpad ? 800 : .infinity)
            .background(Color.cardBG)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func datePickerSection(selectedDate: Binding<Date>) -> some View {
        HStack {
            Spacer()
            DatePicker(
                "",
                selection: selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(accentColor.opacity(0.4), lineWidth: 1)
                    )
            )
            .frame(maxWidth: 300)
            Spacer()
        }
        .padding(.vertical, 8)
        .onChange(of: selectedDate.wrappedValue) { newDate in
            modelView.loadEvents()
        }
    }

    @ViewBuilder
    private func emptyEventsList() -> some View {
        EmptyList(color: accentColor, textIcon: "calendar.badge.exclamationmark")
            .padding(.top, 12)
    }
}
