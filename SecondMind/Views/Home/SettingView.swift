import SwiftUI

struct SettingView: View {
    @EnvironmentObject var loginVM: LoginViewModel
    @StateObject var viewModel: ModelViewSettingView
    @Environment(\.modelContext) private var context
    
    @State private var appearAnimation = false
    
    init() {
    
        _viewModel = StateObject(wrappedValue: ModelViewSettingView())
        
    }
   
    var gestorApi = APIClient()
    // Estados
    @State private var isEditing = false
    @State private var changePass = false
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate()
            
            VStack(spacing: 28) {
                
                Header()
                    .frame(height: 40)
                    .padding(.horizontal)
                    .padding(.top, 10)    // 📌 Mismo padding top que en EventsView
                    .padding(.bottom, 5)

                
                
                ScrollView {
                    VStack(spacing: 22) {
                        
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
                            TextField("Nombre",   text: Binding(
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
                            TextField("Email",
                            text: Binding(
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
                                    .fill(Color(Color.black.opacity(0.1)))
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
                        Button(action: { isEditing.toggle()
                            
                            
                            
                        })  {
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
                        
                        // Botón mostrar contraseñas
                        Button(action: { changePass.toggle() }) {
                            Text("Cambiar contraseña")
                                .foregroundColor(.blue)
                                .bold()
                        }
                        
                        // Campos de contraseña
                        if changePass && viewModel.service != "googleLogin" {
                            VStack(spacing: 16) {
                                Text("Contraseña nueva")
                                            .font(.body)
                                            .foregroundColor(.black)
                                SecureField("Contraseña nueva", text: $viewModel.newpassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                Text("Confirmar contraseña")
                                            .font(.body)
                                            .foregroundColor(.black)
                                SecureField("Confirmar contraseña", text: $viewModel.confirmPassword)
                                    .padding()
                                    .background(Color.black.opacity(0.1), in: RoundedRectangle(cornerRadius: 15))
                                
                                Text("La contraseña debe tener al menos 8 caracteres 🔑")
                                    .font(.footnote)
                                    .foregroundColor(.black)
                                // Botón editar/guardar
                                if let error = loginVM.errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                        .bold()
                                }
                                
                                // 🔘 Botón guardar contraseña (estilo LoginView)
                                Button(action: {
                                    if viewModel.newpassword.count < 8 {
                                        loginVM.errorMessage = "La contraseña debe tener al menos 8 caracteres ❌"
                                        return
                                    }
                                    if viewModel.newpassword != viewModel.confirmPassword {
                                        loginVM.errorMessage = "Las contraseñas no coinciden ⚠️"
                                        return
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
                                }
                            }
                        }
                        
                        // Mensajes de error
                      
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
            }
            .onAppear {
                viewModel.setContext(context: context)
            }
        }
    }
}
