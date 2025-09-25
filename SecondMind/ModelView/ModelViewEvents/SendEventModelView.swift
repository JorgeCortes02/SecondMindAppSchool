//
//  SendEventModelView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 25/9/25.
//

import Foundation
import Contacts

@MainActor
class SendReminderViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var contacts: [CNContact] = []
    @Published var filteredContacts: [CNContact] = []
    @Published var searchText: String = "" {
        didSet { filterContacts(query: searchText) }
    }
    @Published var isLoading: Bool = false
    @Published var message: String?
    @Published var errorMessage: String?

    private var token: String = ""
    private var event: Event?

    func setup(event: Event, token: String) {
        self.event = event
        self.token = token
        loadContacts()
    }

    func loadContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else {
                Task { @MainActor in
                    self.errorMessage = "❌ Acceso a contactos denegado. Revisa Ajustes."
                }
                return
            }
            let keys = [CNContactGivenNameKey,
                        CNContactFamilyNameKey,
                        CNContactEmailAddressesKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            var temp: [CNContact] = []
            try? store.enumerateContacts(with: request) { contact, _ in
                if !contact.emailAddresses.isEmpty {
                    temp.append(contact)
                }
            }
            Task { @MainActor in self.contacts = temp }
        }
    }

    func filterContacts(query: String) {
        if query.isEmpty {
            filteredContacts = []
        } else {
            filteredContacts = contacts.filter {
                $0.givenName.lowercased().contains(query.lowercased()) ||
                $0.familyName.lowercased().contains(query.lowercased())
            }
        }
    }

    func selectEmail(_ email: String) {
        self.email = email
        self.searchText = ""
        self.filteredContacts = []
    }

    func sendReminder() {
        guard let event = event else { return }
        guard !email.isEmpty else {
            errorMessage = "Introduce un email válido."
            return
        }

        isLoading = true
        message = nil
        errorMessage = nil

        APIClient.shared.sendReminder(email: email, event: event, token: token)

        // ⚡ Simulación de resultado (realmente deberías esperar la respuesta del servidor)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.message = "✅ Recordatorio enviado a \(self.email)"
            self.email = ""
        }
    }
}
