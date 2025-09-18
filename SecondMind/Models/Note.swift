import Foundation

struct Note: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
    let date: Date
    let event: EventDTO?   // 👈 por ahora siempre nil en las pruebas
}
