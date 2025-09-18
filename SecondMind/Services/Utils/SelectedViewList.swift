//
//  SelectedViewList.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/6/25.
//

import SwiftUI

class SelectedViewList : ObservableObject {
    @Published var selectedTab : Int  = 0
    @Published var selectedView : Int = 0
}
