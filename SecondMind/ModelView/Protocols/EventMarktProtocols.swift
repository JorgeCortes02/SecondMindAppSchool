//
//  EventMarktProtocoll.swift
//  SecondMind
//
//  Created by Jorge Cortés on 3/11/25.
//

import Foundation
import SwiftData

/// Protocolo base para ViewModels que gestionan listas de eventos.
 protocol BaseEventViewModel: ObservableObject {
    
    /// Lista de eventos cargados (filtrados, procesados).
    var events: [Event] { get set }
     var selectedData: Date { get set }
    /// Pestaña seleccionada (por ejemplo: 0 = activos, 1 = finalizados).
    var selectedTab: Int { get set }
    
    /// Contexto de persistencia (puede ser opcional).
    var context: ModelContext? { get set }
    
    /// Configura el contexto de persistencia.
    func setContext(_ context: ModelContext)
    
    /// Carga eventos según el estado (`global` o filtrados por fecha).
    func loadEvents()
}
