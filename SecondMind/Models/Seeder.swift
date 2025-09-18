import Foundation
import SwiftData

struct DataSeeder {
    static func seed(in context: ModelContext) {
        // 1. Verificar si ya existen proyectos
        let existingProjects: [Project]
        do {
            existingProjects = try context.fetch(FetchDescriptor<Project>())
        } catch {
            print("❌ Error al consultar proyectos: \(error)")
            return
        }
        guard existingProjects.isEmpty else {
            // Si ya hay proyectos, no volver a insertar
            return
        }

        let now = Date()
        let calendar = Calendar.current

        // 2. Crear dos proyectos de ejemplo
        for projectIndex in 1...2 {
            // Ajuste: nombre del parámetro endDate (antes endDare)
            let project = Project(
                title: "Proyecto \(projectIndex)",
                endDate: calendar.date(byAdding: .day, value: 60, to: now),
                status: .on
            )
            context.insert(project)

            // 3. Para cada proyecto, crear 10 eventos
            for eventIndex in 1...10 {
                let daysOffset = Int.random(in: 0..<30)
                let eventEndDate = calendar.date(byAdding: .day, value: daysOffset, to: now)!

                // Ajuste: Event init con parámetros (name → title, endDate, status, project)
                let event = Event(
                    name: "Evento \(projectIndex)-\(eventIndex)",
                    endDate: eventEndDate,
                    status: .on,
                    project: project
                )
                context.insert(event)
                project.events.append(event)

                // 4. Para cada evento, crear 3 tareas asociadas
                for taskIndex in 1...3 {
                    let taskEndDate = calendar.date(byAdding: .day, value: taskIndex, to: eventEndDate)

                    // Ajuste: TaskItem init con endDate, project, event, status
                    let task = TaskItem(
                        title: "Tarea evento \(projectIndex)-\(eventIndex)-\(taskIndex)",
                        endDate: taskEndDate,
                        project: project,
                        event: event,
                        status: .on,
                        descriptionTask: "Descripción de tarea \(projectIndex)-\(eventIndex)-\(taskIndex)"
                    )
                    context.insert(task)
                    event.tasks.append(task)
                    project.tasks.append(task)
                }

                // 5. (Opcional) Para cada evento, añadir un documento de ejemplo
                // Si prefieres no insertar documentos de prueba, puedes comentar estas líneas.
                let sampleDocURL = URL(string: "file:///tmp/documento_\(projectIndex)_\(eventIndex).pdf")!
                let document = UploadedDocument(
                    title: "Documento \(projectIndex)-\(eventIndex)",
                    localURL: sampleDocURL,
                    event: event
                )
                context.insert(document)
                event.documents.append(document)
            }

            // 6. Crear 15 tareas generales (sin evento específico) para este proyecto
            for taskIndex in 1...15 {
                let randomOffset = Int.random(in: 0..<30)
                let taskEndDate = calendar.date(byAdding: .day, value: randomOffset, to: now)

                let task = TaskItem(
                    title: "Tarea general \(projectIndex)-\(taskIndex)",
                    endDate: taskEndDate,
                    project: project,
                    status: .on,
                    descriptionTask: nil // Sin descripción adicional
                )
                context.insert(task)
                project.tasks.append(task)
            }
        }

        // 7. Crear tareas “standalone” fuera de cualquier proyecto o evento

        let standaloneTask1 = TaskItem(
            title: "Estudiar SwiftData",
            endDate: calendar.date(byAdding: .day, value: 1, to: now),
            project: nil,
            event: nil,
            status: .on,
            descriptionTask: "Repasar documentación oficial de SwiftData"
        )
        context.insert(standaloneTask1)

        let standaloneTask2 = TaskItem(
            title: "Leer ejemplos de Relationship en SwiftData",
            endDate: nil,
            project: nil,
            event: nil,
            status: .on,
            descriptionTask: nil
        )
        context.insert(standaloneTask2)

        let standaloneTask3 = TaskItem(
            title: "Configurar ambiente de pruebas",
            endDate: nil,
            project: nil,
            event: nil,
            status: .on,
            descriptionTask: "Instalar simulador, limpiar datos previos"
        )
        context.insert(standaloneTask3)

        print("✅ Datos de ejemplo insertados correctamente")
    }
}
