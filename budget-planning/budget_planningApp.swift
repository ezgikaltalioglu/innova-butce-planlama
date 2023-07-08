//
//  budget_planningApp.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 7.07.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let rememberMe = UserDefaults.standard.bool(forKey: "RememberMe")
        
        if rememberMe {
            let email = UserDefaults.standard.string(forKey: "UserEmail")
            let password = UserDefaults.standard.string(forKey: "UserPassword")
            
            if let email = email, let password = password {
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("Otomatik giriş başarısız oldu: \(error.localizedDescription)")
                    } else {
                        print("Otomatik giriş başarılı!")
                    }
                }
            }
        }
        
        return true
    }
    
    
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
            }
        }
    }
}

