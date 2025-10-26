//
//  glassButtonAction.swift
//  SecondMind
//
//  Created by Jorge Cortés on 26/10/25.
//
import SwiftUI


struct glassButtonBar: View {
    
    var funcAddButton: ()  -> Void
    var funcSyncButton: () async -> Void
    var funcCalendarButton: ()  -> Void
    var color: Color
    @Binding var selectedTab: Int
    
    @Binding  var isSyncing: Bool
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    
    
    var body: some View {
        
        HStack(spacing: 14) {
            Spacer()
            
            // 💻 iPad (regular width): 🔄 + ➕
            
            if #available(iOS 26.0, *) {
                
                if sizeClass == .regular {
                    
                    BaseActionButton(icon: isSyncing ? "arrow.triangle.2.circlepath.circle" : "arrow.clockwise", color: color, action:  {
                        
                        Task{
                            isSyncing.toggle()
                            await funcSyncButton()
                            isSyncing.toggle()
                        }
                        
                    }).disabled(isSyncing)
                    
                }
                
                if (selectedTab == 0 && color == .eventButtonColor) || (selectedTab == 1 && color == .taskButtonColor) &&
                   sizeClass == .compact {
                    
                    BaseActionButton(icon: "calendar", color: color, action: funcCalendarButton)
                }
                BaseActionButton(icon: "plus", color: color, action: funcAddButton)
                
            }
            
        }
        .padding(.trailing, 30)
        .padding(.bottom, sizeClass == .regular ? 90 :  150)
    }
    
    
}
