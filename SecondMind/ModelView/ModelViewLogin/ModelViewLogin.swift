import Foundation
import GoogleSignIn
import os
import SwiftUI   // 👈 necesario para withAnimation

class LoginViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil   // Para mostrar errores bonitos
    @Published var isLoading = false
    @Published var showSuccessModal = false
    @Published var successMessage: String? = nil   // 👈 aquí está la que faltaba
  
    private let tokenKey = "SecondMindAuthToken"
    private let baseURL = "https://secondmind-h6hv.onrender.com/auth"
    
    
    @Published var userSession = UserSession()
    
    init() {
        if let tokenData = KeychainHelper.standard.read(service: tokenKey, account: "SecondMind"),
           let token = String(data: tokenData, encoding: .utf8) {
       
            isAuthenticated = true
        }
    }
    
    // MARK: - Google
    func signInWithGoogle() async {
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            NSLog("❌ No se encontró rootViewController")
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            if let token = result.user.idToken?.tokenString {
                sendGoogleTokenToServer(idToken: token)
            }
        } catch {
            NSLog("❌ Error en login con Google: %@", error.localizedDescription)
        }
    }
    
    private func sendGoogleTokenToServer(idToken: String) {
        guard let url = URL(string: "\(baseURL)/google") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["idToken": idToken])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.setError("No se pudo conectar con Google 🌐 (\(error.localizedDescription))")
                return
            }
            self.handleAuthResponse(data: data, response: response)
        }.resume()
    }
    
    // MARK: - Validaciones rápidas
    private func validateFields(email: String, password: String) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            setError("Por favor, completa todos los campos ✏️")
            return false
        }
        
        guard email.contains("@"), email.contains(".") else {
            setError("Introduce un correo válido 📧")
            return false
        }
        
        return true
    }
    
    func register(email: String, password: String, name: String) {
        guard validateFields(email: email, password: password) else { return }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password, "name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false } // ✅ se apaga la ruedecita
            
            if let error = error {
                self.setError("No se pudo conectar con el servidor 🌐 (\(error.localizedDescription))")
                return
            }
            
            // Manejar respuesta
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // ✅ Éxito → mostramos modal
                DispatchQueue.main.async {
                    self.showSuccessModal = true
                }
            } else {
                self.handleAuthResponse(data: data, response: response)
            }
        }.resume()
    }
    // MARK: - Login propio
    func login(email: String, password: String) {
        guard validateFields(email: email, password: password) else { return }
        
        guard let url = URL(string: "\(baseURL)/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.setError("No se pudo conectar con el servidor 🌐 (\(error.localizedDescription))")
                return
            }
            self.handleAuthResponse(data: data, response: response)
        }.resume()
    }
    
    // MARK: - Procesar respuesta
    private func handleAuthResponse(data: Data?, response: URLResponse?) {
        guard let data = data else {
            setError("Sin datos de respuesta del servidor ⚠️")
            return
        }
#if DEBUG
if let raw = String(data: data, encoding: .utf8) {
    os_log("📦 Respuesta backend: %{public}@", raw)
}
#endif
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let serverError = json["error"] as? String {
                mapServerError(serverError)
            } else {
                setError("Error inesperado del servidor ⚡️")
            }
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let tokenString = json["token"] as? String,
               let tokenData = tokenString.data(using: .utf8) {
                
                // ✅ Login normal, guardamos token
                KeychainHelper.standard.save(tokenData, service: self.tokenKey, account: "SecondMind")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.errorMessage = nil
                }
                
                if let userDict = json["user"] as? [String: Any],
                   let id = userDict["id"] as? String,
                   let name = userDict["name"] as? String,
                   let email = userDict["email"] as? String,
                   let service = userDict["service"] as? String {

                    self.userSession.setData(
                        id: Int(id) ?? 0, // lo conviertes a Int si quieres, si falla usa 0
                        name: name,
                        enteremail: email,
                        service: service
                    )
                }
            } else if let message = json["message"] as? String {
                // ✅ Caso de registro: cuenta creada pero pendiente de verificar
                DispatchQueue.main.async {
                    self.showSuccessModal = true   // 👈 ya lo tienes en tu LoginView
                    self.successMessage = message  // 👈 crea esta @Published si quieres personalizar
                    self.isAuthenticated = false
                }
            } else {
                setError("⚠️ Respuesta inesperada del servidor.")
            }
        }
    }
    
    // MARK: - Mapear errores del servidor
    private func mapServerError(_ serverError: String) {
        var friendlyMessage = "Error inesperado ❌"
        if serverError.contains("registrado") {
            friendlyMessage = "Ese correo ya tiene una cuenta creada 🚫"
        } else if serverError.contains("Credenciales inválidas") {
            friendlyMessage = "Correo o contraseña incorrectos ❌"
        } else if serverError.contains("Falta token") {
            friendlyMessage = "Tu sesión ha caducado, vuelve a iniciar sesión 🔑"
        }
        setError(friendlyMessage)
    }
    
    private func setError(_ message: String) {
        DispatchQueue.main.async {
            withAnimation {
                self.errorMessage = message
                self.isAuthenticated = false
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        KeychainHelper.standard.delete(service: tokenKey, account: "SecondMind")
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }                                                                                                          
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.errorMessage = nil
        }
    }
    
    private func validateFields(email: String, password: String, confirmPassword: String? = nil, name: String? = nil) -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            setError("Por favor, completa todos los campos ✏️")
            return false
        }

        guard email.contains("@"), email.contains(".") else {
            setError("Introduce un correo válido 📧")
            return false
        }

        if let name = name, name.contains(" ") {
            setError("El nombre no puede contener espacios 🚫")
            return false
        }

        guard password.count >= 8 else {
            setError("La contraseña debe tener al menos 8 caracteres 🔒")
            return false
        }

        if let confirmPassword = confirmPassword, confirmPassword != password {
            setError("Las contraseñas no coinciden ⚠️")
            return false
        }

        return true
    }
    
    
    
  
    
}
