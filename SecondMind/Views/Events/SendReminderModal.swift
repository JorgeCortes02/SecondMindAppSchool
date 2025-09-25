import SwiftUI
import Contacts

struct SendReminderModal: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var loginVM: LoginViewModel
    let event: Event
    @StateObject private var viewModel = SendReminderViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Caja principal
                VStack(spacing: 18) {
                    
                    // Campo de búsqueda
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Buscar contacto")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Introduce un nombre...", text: $viewModel.searchText)
                            .padding(12)
                            .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                            .cornerRadius(12)
                            .onChange(of: viewModel.searchText) { _ in
                                viewModel.filterContacts(query: viewModel.searchText)
                            }
                    }
                    
                    // Lista de contactos estilizada
                    if !viewModel.filteredContacts.isEmpty {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(viewModel.filteredContacts.prefix(5), id: \.identifier) { contact in
                                    ForEach(contact.emailAddresses, id: \.self) { emailValue in
                                        Button {
                                            viewModel.selectEmail(String(emailValue.value))
                                        } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("\(contact.givenName) \(contact.familyName)")
                                                        .font(.body)
                                                        .foregroundColor(.primary)
                                                    Text(emailValue.value as String)
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                                Spacer()
                                            }
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 3)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 180)
                    }
                    
                    // Campo manual
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email manual")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("usuario@email.com", text: $viewModel.email)
                            .padding(12)
                            .background(Color(red: 240/255, green: 240/255, blue: 245/255))
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // Botón enviar
                    Button {
                        viewModel.sendReminder()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Enviar recordatorio")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.eventButtonColor)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                    .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                    
                    // ✅ Mensajes de feedback
                    if let message = viewModel.message {
                        Text(message)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.85))
                            )
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .scale))
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.85))
                            )
                            .padding(.top, 12)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 5)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .background(BackgroundColorTemplate()) // 👈 coherente con EventDetall
            .navigationTitle("Enviar recordatorio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .onAppear {
                viewModel.setup(event: event, token: loginVM.getToken() ?? "")
            }
        }
        .presentationDetents([.height(450)]) // 👈 altura compacta
    }
}
