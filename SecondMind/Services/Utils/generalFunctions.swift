//
//  generalFunctions.swift
//  SecondMind
//
//  Created by Jorge Cortés on 15/6/25.
//

import SwiftUI
import SwiftData

class generalFunctions : ObservableObject {
   
    @Published var dismissView: Bool = false
    
    
    func dismissViewFunc(){
        dismissView = true
    }
    
    
    func pastEvent(eventList : inout [Event], context : ModelContext) {
        
      
        let actualDate = Date()
        
      
        
         var isModified : Bool = false
        
        for event in eventList {
            let deleteHourDate = Calendar.current.date(byAdding: .hour, value: +1, to: event.endDate)!
            if actualDate >= deleteHourDate && event.status == .on{
                
                event.status = .off
               
                isModified = true
                Task{
                    
                    await SyncManagerUpload.shared.uploadEvent(event: event)
                    
                }
            }
        }
        
        if isModified {
            do {
                try context.save()
                
            } catch {
                print("❌ Error al guardar: \(error)")
            }
            isModified = false
        }
        
        
    }
    
    
    func formattedDate(_ date: Date) -> String {
        
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
            formatter.dateStyle = .long
            
            return formatter.string(from: date)
        

    }
    
    func formattedDateAndHour(_ date: Date) -> String {
        
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "es_ES")
        formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            return formatter.string(from: date)
        

    }
     func extractHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
  
    
}
