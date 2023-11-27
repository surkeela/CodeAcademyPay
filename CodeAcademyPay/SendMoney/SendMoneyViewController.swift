//
//  SendMoneyViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import UIKit

class SendMoneyViewController: UIViewController {

    private let transactionViewModel = TransactionViewModel()
    private let userViewModel = UserManagementViewModel()
    var users: [User] = []
//    private let token: String = ""
    
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var sumTextField: UITextField!
    @IBOutlet weak private var noteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        userViewModel.getAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                // Handle the failure to fetch users
                print("Failed to fetch users: \(error)")
                // Show an alert or update UI to inform the user about the error
            }
        }
    }
    
    private func sendMoney() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else {
            print("Token not found in UserDefaults")
            return
        }
        
        guard let receiver = phoneNumberTextField.text, //"863333333"
              let amount = sumTextField.text,
              !receiver.isEmpty, !amount.isEmpty else { return }
        
        let currency = "EUR"
        let description = noteTextField.text ?? "" //"Sending money to user 863333333"
        
        transactionViewModel.createTransaction(receiver: receiver, amount: amount, currency: currency, description: description, bearerToken: token) { [weak self] result in
            switch result {
            case .success(let transactionResponse):
                // Handle successful transaction creation
                print("Transaction created: \(transactionResponse)")
                DispatchQueue.main.async {
                    self?.phoneNumberTextField.text = ""
                    self?.sumTextField.text = ""
                    self?.noteTextField.text = ""
                    
                    self?.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                // Handle transaction creation failure
                print("Transaction creation failed: \(error)")
                // Show an alert or update UI to inform the user about the failure
            }
        }
    }

    @IBAction func sendTapped(_ sender: Any) {
        sendMoney()
    }
    
}
