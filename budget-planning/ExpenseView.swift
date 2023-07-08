//
//  ExpenseView.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 8.07.2023.
//
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ExpenseView: View {
    @State private var expenseName: String = ""
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var expenses: [Expense] = [] 
    var body: some View {
        VStack {
            Text("Gider Ekle")
                .font(.largeTitle)
                .padding()
            
            TextField("Gider Adı", text: $expenseName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Tutar", text: $amount)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                .padding()
            
            Button(action: {
                addExpense()
            }) {
                Text("Gider Ekle")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            List(expenses, id: \.id) { expense in
                VStack(alignment: .leading) {
                    Text(expense.name)
                        .font(.headline)
                    Text("Tutar: \(String(format: "%.2f", expense.amount))")
                        .font(.subheadline)
                    Text("Tarih: \(expense.date)")
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .onAppear {
            fetchExpenses()
        }
    }
    
    func addExpense() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu bulunamadı.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let db = Firestore.firestore()
        let expenseRef = db.collection("users").document(currentUser.uid).collection("expense")
        
        let expenseData = Expense(name: expenseName, amount: Double(amount) ?? 0, date: dateString)
        
        do {
            try expenseRef.addDocument(from: expenseData)
            showAlert(title: "Başarılı", message: "Gider başarıyla eklendi.")
            print("Gider başarıyla eklendi.")
            
            fetchExpenses()
            
        } catch let error {
            showAlert(title: "Hata", message: "Gider ekleme hatası: \(error.localizedDescription)")
            print("Gider ekleme hatası: \(error.localizedDescription)")
        }
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
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct Expense: Codable, Identifiable {
    var id = UUID()
    let name: String
    let amount: Double
    let date: String
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView()
    }
}

