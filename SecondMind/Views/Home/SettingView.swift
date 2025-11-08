import SwiftUI

struct SettingView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject var viewModel: ModelViewSettingView
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @State private var appearAnimation = false
    @State private var isEditing = false
    @State private var changePass = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
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
                    VStack(alignment: .leading, spacing: 22) {
                        
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
                                .font(.body).bold()
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
                                    .font(.subheadline).bold()
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
                                .font(.body).bold()
                                .foregroundColor(.black)
                            TextField("Email", text: Binding(
                                get: { loginVM.userSession.email },
                                set: { loginVM.userSession.email = $0 }
                            ))
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                            .padding()
                            .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                            .onChange(of: loginVM.userSession.email) { _ in loginVM.errorMessage = nil }
                        } else {
                            HStack {
                                Text("Email:")
                                    .font(.subheadline).bold()
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
                                .font(.body).bold()
                                .foregroundColor(.black)
                            TextField("Service", text: $loginVM.userSession.service)
                                .disabled(true)
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                        } else {
                            HStack {
                                Text("Servicio:")
                                    .font(.subheadline).bold()
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

                    
                        Button(action: {
                            if isEditing {
                                let oldName = loginVM.userSession.name
                                let oldEmail = loginVM.userSession.email
                                let name = loginVM.userSession.name.trimmingCharacters(in: .whitespacesAndNewlines)
                                let email = loginVM.userSession.email.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                // ✅ Validaciones
                                guard !name.isEmpty, name.count <= 20 else {
                                    loginVM.errorMessage = "❌ El nombre no puede estar vacío ni tener más de 20 caracteres."
                                    loginVM.userSession.name = oldName
                                    return
                                }

                                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                                let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                                guard emailPred.evaluate(with: email) else {
                                    loginVM.errorMessage = "❌ El correo electrónico no es válido"
                                    loginVM.userSession.email = oldEmail
                                    return
                                }

                                guard let token = loginVM.getToken() else {
                                    loginVM.errorMessage = "❌ No se encontró el token de sesión"
                                    return
                                }

                                Task {
                                    do {
                                        try await APIClient.shared.updateProfile(
                                            token: token,
                                            name: name,
                                            email: email
                                        )
                                        await MainActor.run {
                                            loginVM.errorMessage = "✅ Perfil actualizado correctamente"
                                            showSuccessAlert = true
                                            isEditing = false  // 🔹 Aquí sí se cambia correctamente
                                        }
                                    } catch {
                                        await MainActor.run {
                                            loginVM.errorMessage = "❌ Error: \(error.localizedDescription)"
                                        }
                                    }
                                }
                            } else {
                                withAnimation {
                                    isEditing = true
                                }
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
                                    .font(.body).bold()
                                    .foregroundColor(.black)
                                SecureField("Contraseña nueva", text: $newPassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("Confirmar contraseña")
                                    .font(.body).bold()
                                    .foregroundColor(.black)
                                SecureField("Confirmar contraseña", text: $newPasswordConfirm)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("Contraseña Actual")
                                    .font(.body).bold()
                                    .foregroundColor(.black)
                                SecureField("Contraseña Actual", text: $currentPassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("La contraseña debe tener al menos 8 caracteres 🔑")
                                    .font(.footnote).bold()
                                    .foregroundColor(.black)
                                
                                // Mostrar error también aquí
                                if let error = loginVM.errorMessage , showErrorAlert{
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
                                        showErrorAlert = false
                                        return
                                    }
                                    if newPassword != newPasswordConfirm {
                                        loginVM.errorMessage = "Las contraseñas no coinciden ⚠️"
                                        showErrorAlert = false
                                        return
                                    }
                                    guard let token = loginVM.getToken() else {
                                        loginVM.errorMessage = "❌ No se encontró el token de sesión"
                                        showErrorAlert = false
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
                                                showErrorAlert = false
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
                } .frame(
                    maxWidth: hSizeClass == .regular ? 800 : .infinity, // 👈 Solo limita en iPad
                    alignment: .leading
                )
                .scrollBounceBehavior(.basedOnSize)
                .modifier(GlassContainerProfile())
                
                Spacer()
                
                Text("© 2025 SecondMind ✨")
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.bottom, 12)
            }.alert("Éxito", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {
                    showSuccessAlert = false
                }
            } message: {
                Text("✅ La información se cambió correctamente")
            }
            .onAppear {
                viewModel.setContext(context: context)
            }
        }
    }
}
