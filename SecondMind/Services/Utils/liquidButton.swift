//
//  liquidButton.swift
//  SecondMind
//
//  Created by Jorge Cortés on 14/9/25.
//

import SwiftUI

struct liquidButton: ViewModifier  {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 35, style: .continuous)

        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
        } 
    }
}
