import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @Environment(\.horizontalSizeClass) var sizeClass   // 👈 Detecta iPhone/iPad
    @State private var appearAnimation = false
    
    // Campos
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var isRegisterMode = false
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate()
            
            VStack {
                Spacer()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // 🪪 Logo + título
                        VStack(spacing: 16) {
                            Image("logotitle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .opacity(appearAnimation ? 1 : 0)
                                .scaleEffect(appearAnimation ? 1 : 0.85)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7),
                                           value: appearAnimation)
                            
                            HStack(spacing: 5) {
                                Text("Second")
                                    .font(.system(size: 45, weight: .semibold))
                                    .foregroundColor(.taskButtonColor)
                                
                                Text("Mind")
                                    .font(.system(size: 45, weight: .semibold))
                                    .foregroundColor(Color(red: 47/255, green: 129/255, blue: 198/255))
                            }
                            
                            Text("Organiza. Enfócate. Avanza 🚀")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        
                        Divider().padding(.vertical, 8)
                        
                        // 📋 Formulario adaptativo
                        if sizeClass == .regular {
                            // 💻 iPad layout ancho
                            VStack(spacing: 20) {
                                HStack(spacing: 16) {
                                    TextField("Email", text: $email)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .padding()
                                        .background(.ultraThinMaterial,
                                                    in: RoundedRectangle(cornerRadius: 15))
                                        .onChange(of: email) { _ in loginVM.errorMessage = nil }
                                    
                                    SecureField("Contraseña", text: $password)
                                        .padding()
                                        .background(.ultraThinMaterial,
                                                    in: RoundedRectangle(cornerRadius: 15))
                                        .onChange(of: password) { _ in loginVM.errorMessage = nil }
                                }
                                
                                if isRegisterMode {
                                    HStack(spacing: 16) {
                                        SecureField("Confirmar contraseña", text: $confirmPassword)
                                            .padding()
                                            .background(.ultraThinMaterial,
                                                        in: RoundedRectangle(cornerRadius: 15))
                                            .onChange(of: confirmPassword) { _ in loginVM.errorMessage = nil }
                                        
                                        TextField("Nombre", text: $name)
                                            .textInputAutocapitalization(.never)
                                            .padding()
                                            .background(.ultraThinMaterial,
                                                        in: RoundedRectangle(cornerRadius: 15))
                                            .onChange(of: name) { _ in loginVM.errorMessage = nil }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("La contraseña debe tener al menos 8 caracteres 🔑")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        Text("El nombre no puede contener espacios 🚫")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: 700) // 👈 ancho máximo en iPad
                            
                        } else {
                            // 📱 iPhone layout columna
                            VStack(spacing: 16) {
                                TextField("Email", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(.ultraThinMaterial,
                                                in: RoundedRectangle(cornerRadius: 15))
                                    .onChange(of: email) { _ in loginVM.errorMessage = nil }
                                
                                SecureField("Contraseña", text: $password)
                                    .padding()
                                    .background(.ultraThinMaterial,
                                                in: RoundedRectangle(cornerRadius: 15))
                                    .onChange(of: password) { _ in loginVM.errorMessage = nil }
                                
                                if isRegisterMode {
                                    SecureField("Confirmar contraseña", text: $confirmPassword)
                                        .padding()
                                        .background(.ultraThinMaterial,
                                                    in: RoundedRectangle(cornerRadius: 15))
                                        .onChange(of: confirmPassword) { _ in loginVM.errorMessage = nil }
                                    
                                    Text("La contraseña debe tener al menos 8 caracteres 🔑")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    
                                    TextField("Nombre", text: $name)
                                        .textInputAutocapitalization(.never)
                                        .padding()
                                        .background(.ultraThinMaterial,
                                                    in: RoundedRectangle(cornerRadius: 15))
                                        .onChange(of: name) { _ in loginVM.errorMessage = nil }
                                    
                                    Text("El nombre no puede contener espacios 🚫")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 28)
                        }
                        
                        if loginVM.isLoading {
                            ProgressView("Cargando...")
                                .padding()
                        }
                        
                        // 🔘 Botón login/registro
                        Button(action: {
                            if isRegisterMode {
                                if password.count < 8 {
                                    loginVM.errorMessage = "La contraseña debe tener al menos 8 caracteres ❌"
                                    return
                                }
                                if password != confirmPassword {
                                    loginVM.errorMessage = "Las contraseñas no coinciden ⚠️"
                                    return
                                }
                                loginVM.register(email: email, password: password, name: name)
                            } else {
                                loginVM.login(email: email, password: password)
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text(isRegisterMode ? "Crear cuenta" : "Iniciar sesión")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: sizeClass == .regular ? .infinity : 300) // 👈 más estrecho en móvil
                            .padding()
                            .background(LinearGradient(colors: [Color.blue, Color.indigo],
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .frame(maxWidth: sizeClass == .regular ? 500 : .infinity)
                        .multilineTextAlignment(.center)
                        
                        Button(action: { isRegisterMode.toggle() }) {
                            Text(isRegisterMode ? "¿Ya tienes cuenta? Inicia sesión"
                                 : "¿No tienes cuenta? Regístrate")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .bold()
                        }
                        
                        if let error = loginVM.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .bold()
                        }
                        
                        Divider().padding(.vertical, 8)
                        
                        // 🌍 Botón Google
                        Button(action: {
                            Task {
                                await loginVM.signInWithGoogle()
                               
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Continuar con Google")
                            }
                            .frame(maxWidth: sizeClass == .regular ? .infinity : 300) // 👈 más estrecho en móvil
                            .padding()
                            .background(
                                LinearGradient(colors: [
                                    Color(red: 219/255, green: 68/255, blue: 55/255),
                                    Color(red: 66/255, green: 133/255, blue: 244/255)
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .frame(maxWidth: sizeClass == .regular ? 500 : .infinity)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 30)
                }
                .modifier(GlassContainerImproved())
                
                Spacer()
                
                Text("© 2025 SecondMind ✨")
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.bottom, 12)
            }
            .onAppear { appearAnimation = true }
            .alert("Cuenta creada ✅", isPresented: $loginVM.showSuccessModal) {
                Button("Ir al login", role: .cancel) {
                    loginVM.isAuthenticated = false
                    isRegisterMode = false
                }
            } message: {
                Text("Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión.")
            }
        }
        .environment(\.colorScheme, .light)
    }
}
