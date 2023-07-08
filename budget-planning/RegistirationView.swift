//
//  RegistirationView.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 8.07.2023.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var registrationSuccess = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Kayıt Ol")
                    .font(.largeTitle)
                    .padding()

                TextField("Adınız", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Soyadınız", text: $surname)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("E-posta", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Parola", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    // Kayıt butonuna basıldığında yapılacak işlemler
                    register()
                }) {
                    Text("Kayıt Ol")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
            .navigationBarTitle(Text("Kayıt Ol"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    // Kayıt ekranından çıkış yap
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Vazgeç")
                }
            )
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                // Kayıt başarısız oldu, hata mesajını kullanıcıya gösterin
                showAlert(title: "Hata", message: "Kayıt başarısız.")
                print("Kayıt başarısız oldu: \(error.localizedDescription)")
            } else {
                // Kayıt başarılı, kullanıcıyı giriş ekranına yönlendirin veya otomatik olarak giriş yapın
                print("Kayıt başarılı!")
                showAlert(title: "Başarılı", message: "Kayıt başarılı.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct RegistirationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistirationView()
    }
}
