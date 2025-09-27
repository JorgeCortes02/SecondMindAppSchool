//
//  EventDetallModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 4/9/25.
//
import SwiftUI
import SwiftData
import Foundation

public class EventDetallModelView: ObservableObject {
    
    
   @Published var projects: [Project] = []
    
    private var context: ModelContext?
    
    
    
    init(context: ModelContext? = nil){
        
        self.context = context
        
    }
    
    func setContext (context: ModelContext) {
        self.context = context
    }
    
    public func getProjects() {
        if let context = self.context{
            
            projects = HomeApi.downdloadProjectsFrom(context: context)
        }
        
    }
    
     func saveEvent(event: Event) {
        if let context = self.context{
            
            
                  do {
                         // Buscar la tarea real en el contexto

                             // Guardar los cambios en la base de datos
                             try context.save()
                      Task{
                          
                          await SyncManagerUpload.shared.uploadEvent(event: event)
                          
                      }

                     } catch {
                         print("❌ Error al guardar: \(error)")
                     }
        }
    }
    
    func deleteEvent (event: Event) {
        if let context = self.context{
            
            do {
                
                context.delete(event)
                try context.save()
                
                Task{
                   await SyncManagerUpload.shared.deleteEvent(event: event)
                }
               
            }catch {
                
                print("❌ Error al guardar cambios después de eliminar: \(error)")

            }
                
            }
        }
    }

