//
//  HeaderTipeOfEvent.swift
//  SecondMind
//
//  Created by Jorge Cortés on 3/11/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Spacer()
            Text("\(count)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        
        Rectangle()
            .fill(Color.primary.opacity(0.1))
            .frame(height: 1)
            .padding(.top, 4)
    }
}
