//
//  SecondMindApp.swift
//  SecondMind
//
//  Created by Jorge Cortés on 28/5/25.
//

import SwiftUI
import SwiftData

@main
struct SecondMindApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var navModel = SelectedViewList()
    @StateObject var utilFunctions = generalFunctions()
    @StateObject private var loginViewModel = LoginViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate


    
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            Event.self,
            TaskItem.self,
            LastDeleteTask.self,
        ])
        let modelConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfig]
            )

            // Ejecutar seeder justo después de crear el container
        

            return container
        } catch {
            fatalError("❌ No se pudo crear el ModelContainer: \(error)")
        }
    }()
    // El init del App se ejecuta al lanzar (antes de construir las vistas)
       
    var body: some Scene {
        WindowGroup {
            
            if loginViewModel.isAuthenticated {
                ContentView().environmentObject(navModel).environmentObject(utilFunctions)
                    .modelContainer(sharedModelContainer).environmentObject(loginViewModel)
                    .preferredColorScheme(.light).onTapGesture {
                        UIApplication.shared.hideKeyboard()
                    }
                        } else {
                            LoginView()
                                .environmentObject(loginViewModel).onTapGesture {
                                    UIApplication.shared.hideKeyboard()
                                }
                        }
            
            
            
            
        }
    }
}
