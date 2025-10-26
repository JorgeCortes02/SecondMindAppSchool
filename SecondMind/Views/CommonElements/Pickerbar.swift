//
//  Pickervar.swift
//  SecondMind
//
//  Created by Jorge Cortés on 24/10/25.
//
import SwiftUI

// MARK: – Segment Button

import SwiftUI

struct SegmentButton: View {
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
 

    var isSelected: Bool {
        selectedTab == tag
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                selectedTab = tag
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .blue)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}


// MARK: – Picker bar (iPhone)
 struct PickerBar:  View {
    var options: [String]

    @Binding var selectedTab: Int
    @Environment(\.horizontalSizeClass) private var sizeClass

   var body: some View{
       
       if sizeClass == .regular {
           HStack(spacing: 10) {
               ForEach(options.indices, id: \.self){index in
                   
                   SegmentButton(title: options[index], tag: index, selectedTab: $selectedTab)
               
               }
           }
           .padding(.vertical, 10)
           .padding(.horizontal, 20)
           .background(
               RoundedRectangle(cornerRadius: 40)
                   .fill(Color.white.opacity(0.85))
                   .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                   .overlay(
                       RoundedRectangle(cornerRadius: 40)
                           .stroke(Color.eventButtonColor.opacity(0.4), lineWidth: 1)
                   )
           )
           .frame(maxWidth: 360)
           .frame(maxWidth: .infinity)
           .padding(.vertical, 8)
       } else {
           HStack(spacing: 10) {
               ForEach(options.indices, id: \.self){index in
                   
                   SegmentButton(title: options[index], tag: index, selectedTab: $selectedTab)
               
               }
           }
           .padding(15)
           .background(Color.cardBG)
           .cornerRadius(40)
           .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
           .padding(.horizontal, 16)
       }
       }
       
       
       
       
       
       
       
        
}
