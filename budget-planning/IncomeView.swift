//
//  IncomeView.swift
//  budget-planning
//
//  Created by Ezgi Kaltalıoğlu on 8.07.2023.
//
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct IncomeView: View {
    @State private var incomeName: String = ""
    @State private var amount: String = ""
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var incomes: [Income] = []
    
    var body: some View {
        VStack {
            Text("Gelir Ekle")
                .font(.largeTitle)
                .padding()
            
            TextField("Gelir Adı", text: $incomeName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Tutar", text: $amount)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            
            DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                .padding()
            
            Button(action: {
                addIncome()
            }) {
                Text("Gelir Ekle")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            
            List(incomes, id: \.id) { income in
                VStack(alignment: .leading) {
                    Text(income.name)
                        .font(.headline)
                    Text("Tutar: \(String(format: "%.2f", income.amount))")
                        .font(.subheadline)
                    Text("Tarih: \(income.date)")
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
            fetchIncomes()
        }
    }
    
    
    func addIncome() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Kullanıcı oturumu bulunamadı.")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: selectedDate)
        
        let db = Firestore.firestore()
        let incomeRef = db.collection("users").document(currentUser.uid).collection("income")
        
        let incomeData = Income(name: incomeName, amount: Double(amount) ?? 0, date: dateString)
        
        do {
            let _ = try incomeRef.addDocument(from: incomeData)
            showAlert(title: "Başarılı", message: "Gelir başarıyla eklendi.")
            print("Gelir başarıyla eklendi.")
            
            
            fetchIncomes()
            
        } catch let error {
            showAlert(title: "Hata", message: "Gelir ekleme hatası: \(error.localizedDescription)")
            print("Gelir ekleme hatası: \(error.localizedDescription)")
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
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct Income: Codable, Identifiable {
    var id = UUID()
    let name: String
    let amount: Double
    let date: String
}

struct IncomeView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeView()
    }
}
