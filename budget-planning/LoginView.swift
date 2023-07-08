//
//  ContentView.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 7.07.2023.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = UserDefaults.standard.bool(forKey: "RememberMe")
    @State private var isRegistering: Bool = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var registrationSuccess = false
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            DashboardView()
        } else {
            VStack {
                Text("Hoş Geldiniz!")
                    .font(.largeTitle)
                    .padding()
                
                TextField("E-posta", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Parola", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Toggle("Beni Hatırla", isOn: $rememberMe)
                    .padding()
                    .onChange(of: rememberMe) { value in
                        UserDefaults.standard.set(value, forKey: "RememberMe")
                    }
                
                Button(action: {
                    login()
                }) {
                    Text("Giriş Yap")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    isRegistering = true
                }) {
                    Text("Kayıt Ol")
                        .foregroundColor(.blue)
                }
                .sheet(isPresented: $isRegistering) {
                    RegistrationView()
                }
            }
            .padding()
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                showAlert(title: "Hata", message: error.localizedDescription)
                print("Giriş başarısız oldu: \(error.localizedDescription)")
            } else {
                print("Giriş başarılı!")
                isLoggedIn = true
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}


