//
//  DashboardView.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 8.07.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct DashboardView: View {
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab {
        case income, dashboard, expense
    }
    
    @State private var incomes: [Income] = []
    @State private var expenses: [Expense] = []
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                switch selectedTab {
                case .income:
                    IncomeView()
                case .dashboard:
                    VStack {
                        Text("Gelirler")
                            .font(.headline)
                        
                        Text("Toplam Gelir: \(formatAmount(calculateTotalIncome()))")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.bottom, 16)
                        
                        List(incomes, id: \.id) { income in
                            VStack(alignment: .leading) {
                                Text(income.name)
                                    .font(.headline)
                                Text("Amount: \(formatAmount(income.amount))")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        
                        Text("Giderler")
                            .font(.headline)
                        
                        Text("Toplam Gider: \(formatAmount(calculateTotalExpense()))")
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.bottom, 16)
                        
                        List(expenses, id: \.id) { expense in
                            VStack(alignment: .leading) {
                                Text(expense.name)
                                    .font(.headline)
                                Text("Amount: \(formatAmount(expense.amount))")
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                    }
                case .expense:
                    ExpenseView()
                }
            }
            
            HStack {
                Button(action: {
                    selectedTab = .income
                }) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .income ? .blue : .black)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    selectedTab = .dashboard
                }) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .dashboard ? .blue : .black)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    selectedTab = .expense
                }) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 24))
                        .foregroundColor(selectedTab == .expense ? .blue : .black)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    logout()
                }) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .background(Color.white)
            .border(Color.gray, width: 1)
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            fetchIncomes()
            fetchExpenses()
        }
    }
    func formatAmount(_ amount: Double) -> String {
        return String(format: "%.2f", amount)
    }
    
    func fetchExpenses() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu bulunamadı.")
            return
        }
        
        let db = Firestore.firestore()
        let expenseRef = db.collection("users").document(currentUser.uid).collection("expense")
        
        expenseRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Giderleri alma hatası: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Gider verileri bulunamadı.")
                return
            }
            
            var expenses: [Expense] = []
            
            for document in snapshot.documents {
                if let expense = try? document.data(as: Expense.self) {
                    expenses.append(expense)
                }
            }
            
            self.expenses = expenses
            
            print("Alınan giderler: \(expenses)")
        }
    }
    func fetchIncomes() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu bulunamadı.")
            return
        }
        
        let db = Firestore.firestore()
        let incomeRef = db.collection("users").document(currentUser.uid).collection("income")
        
        incomeRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Gelirleri alma hatası: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Gelir verileri bulunamadı.")
                return
            }
            
            var incomes: [Income] = []
            
            for document in snapshot.documents {
                if let income = try? document.data(as: Income.self) {
                    incomes.append(income)
                }
            }
            
            self.incomes = incomes
            
            print("Alınan gelirler: \(incomes)")
        }
    }
    
    func calculateTotalIncome() -> Double {
        var totalIncome: Double = 0
        for income in incomes {
            totalIncome += income.amount
        }
        return totalIncome
    }
    
    func calculateTotalExpense() -> Double {
        var totalExpense: Double = 0
        for expense in expenses {
            totalExpense += expense.amount
        }
        return totalExpense
    }
    func logout() {
        let alert = UIAlertController(title: "Çıkış Yap", message: "Çıkış yapmak istediğinize emin misiniz?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Evet", style: .destructive) { _ in
            
            UserDefaults.standard.removeObject(forKey: "kullaniciAdi")
            UserDefaults.standard.removeObject(forKey: "kullaniciEmail")
            
            
            let loginView = LoginView()
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            window.rootViewController = UIHostingController(rootView: loginView)
            window.makeKeyAndVisible()
        }
        alert.addAction(yesAction)
        
        
        let noAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
        alert.addAction(noAction)
        
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}


