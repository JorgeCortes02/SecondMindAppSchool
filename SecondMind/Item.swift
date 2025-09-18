//
//  Item.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
