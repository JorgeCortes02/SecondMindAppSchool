import SwiftUI

struct SettingView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject var viewModel: ModelViewSettingView
    @Environment(\.modelContext) private var context
    
    @State private var appearAnimation = false
    @State private var isEditing = false
    @State private var changePass = false
    @State private var showSuccessAlert = false
    @State var currentPassword: String = ""
    @State var newPassword: String = ""
    @State var newPasswordConfirm: String = ""

    init() {
        _viewModel = StateObject(wrappedValue: ModelViewSettingView())
    }
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate()
            
            VStack(spacing: 28) {
                
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 5)

                ScrollView {
                    VStack(spacing: 22) {
                        
                        // Título
                        HStack {
                            Text("Datos de perfil")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                                .foregroundStyle(Color.taskButtonColor)
                        }
                        
                        // 👤 Nombre
                        if isEditing {
                            Text("Nombre")
                                .font(.body)
                                .foregroundColor(.black)
                            TextField("Nombre", text: Binding(
                                get: { loginVM.userSession.name },
                                set: { loginVM.userSession.name = $0 }
                            ))
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                            .onChange(of: loginVM.userSession.name) { _ in loginVM.errorMessage = nil }
                        } else {
                            HStack {
                                Text("Nombre:")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(loginVM.userSession.name)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.1))
                            )
                        }

                        // 📧 Email
                        if isEditing {
                            Text("Email")
                                .font(.body)
                                .foregroundColor(.black)
                            TextField("Email", text: Binding(
                                get: { loginVM.userSession.email },
                                set: { loginVM.userSession.email = $0 }
                            ))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .disabled(viewModel.service == "googleLogin")
                            .padding()
                            .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                            .onChange(of: loginVM.userSession.email) { _ in loginVM.errorMessage = nil }
                        } else {
                            HStack {
                                Text("Email:")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(loginVM.userSession.email)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.1))
                            )
                        }

                        // 🔑 Service
                        if isEditing {
                            Text("Servicio")
                                .font(.body)
                                .foregroundColor(.black)
                            TextField("Service", text: $loginVM.userSession.service)
                                .disabled(true)
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                        } else {
                            HStack {
                                Text("Servicio:")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                                Text(loginVM.userSession.service)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.black.opacity(0.1))
                            )
                        }
                        
                        // 👇 Mostrar errores centralizados
                        if let error = loginVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .bold()
                        }

                        // Botón guardar/editar
                        Button(action: {
                            if isEditing {
                                let name = loginVM.userSession.name.trimmingCharacters(in: .whitespacesAndNewlines)
                                let email = loginVM.userSession.email.trimmingCharacters(in: .whitespacesAndNewlines)

                                // Validaciones
                                guard !name.isEmpty, !name.contains(" ") else {
                                    loginVM.errorMessage = "❌ El nombre no puede estar vacío ni contener espacios"
                                    return
                                }

                                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                                guard emailPred.evaluate(with: email) else {
                                    loginVM.errorMessage = "❌ El correo electrónico no es válido"
                                    return
                                }

                                guard let token = loginVM.getToken() else {
                                    loginVM.errorMessage = "❌ No se encontró el token de sesión"
                                    return
                                }

                                Task {
                                    do {
                                        let _ = try await APIClient.shared.updateProfile(
                                            token: token,
                                            name: name,
                                            email: email
                                        )
                                        loginVM.errorMessage = "✅ Perfil actualizado correctamente"
                                    } catch {
                                        loginVM.errorMessage = "❌ Error: \(error.localizedDescription)"
                                    }
                                }
                                loginVM.errorMessage = nil
                                isEditing.toggle()
                            } else {
                                isEditing.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text(isEditing ? "Guardar cambios" : "Editar perfil")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.blue, Color.indigo],
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .padding(.top, 8)

                        Divider().padding(.vertical, 10)
                        
                        if viewModel.service != "googleLogin" {
                            Button(action: { changePass.toggle() }) {
                                Text("Cambiar contraseña")
                                    .foregroundColor(.blue)
                                    .bold()
                            }
                        }
                     
                       
                        
                        // Campos de contraseña
                        if changePass  {
                            VStack(spacing: 16) {
                                Text("Contraseña nueva")
                                    .font(.body)
                                    .foregroundColor(.black)
                                SecureField("Contraseña nueva", text: $newPassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("Confirmar contraseña")
                                    .font(.body)
                                    .foregroundColor(.black)
                                SecureField("Confirmar contraseña", text: $newPasswordConfirm)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("Contraseña Actual")
                                    .font(.body)
                                    .foregroundColor(.black)
                                SecureField("Contraseña Actual", text: $currentPassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("La contraseña debe tener al menos 8 caracteres 🔑")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                
                                // Mostrar error también aquí
                                if let error = loginVM.errorMessage , showSuccessAlert{
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .bold()
                                }
                                
                                Button(action: {
                                    if newPassword.count < 8 {
                                        loginVM.errorMessage = "La contraseña debe tener al menos 8 caracteres ❌"
                                        showSuccessAlert = false
                                        return
                                    }
                                    if newPassword != newPasswordConfirm {
                                        loginVM.errorMessage = "Las contraseñas no coinciden ⚠️"
                                        showSuccessAlert = false
                                        return
                                    }
                                    guard let token = loginVM.getToken() else {
                                        loginVM.errorMessage = "❌ No se encontró el token de sesión"
                                        showSuccessAlert = false
                                        return
                                    }
                                    
                                    if !showSuccessAlert{
                                        
                                        Task {
                                            do {
                                                try await APIClient.shared.changePassword(
                                                    token: token,
                                                    currentPassword: currentPassword,
                                                    newPassword: newPassword
                                                )
                                                loginVM.errorMessage = nil
                                                showSuccessAlert = true
                                                // Limpieza de campos
                                                newPassword = ""
                                                newPasswordConfirm = ""
                                                currentPassword = ""
                                                changePass = false
                                            } catch {
                                                loginVM.errorMessage = "❌ Error: \(error.localizedDescription)"
                                            }
                                        }
                                        
                                        showSuccessAlert.toggle()
                                    }
                                    
                                  
                                }) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                        Text("Guardar contraseña")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(colors: [Color.blue, Color.indigo],
                                                               startPoint: .leading,
                                                               endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(25)
                                }                            }
                        }
                        
                        if loginVM.isLoading {
                            ProgressView("Cargando...")
                                .padding()
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 30)
                }
                .scrollBounceBehavior(.basedOnSize)
                .modifier(GlassContainerProfile())
                
                Spacer()
                
                Text("© 2025 SecondMind ✨")
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.bottom, 12)
            }.alert("Éxito", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("✅ La contraseña se cambió correctamente")
            }
            .onAppear {
                viewModel.setContext(context: context)
            }
        }
    }
}
