//
//  SendMoneyViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import UIKit

class SendMoneyViewController: UIViewController {

    let transactionViewModel = TransactionViewModel()
    let userViewModel = UserManagementViewModel()
    var users: [User] = []
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var sumTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
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
    
    func sendMoney() {
        let sendMoneyViewController = SendMoneyViewController()
        navigationController?.pushViewController(sendMoneyViewController, animated: true)
        
         let receiver = "863333333"
         let amount = "1"
         let currency = "EUR"
         let description = "Sending money to user 863333333"

        transactionViewModel.createTransaction(receiver: receiver, amount: amount, currency: currency, description: description, bearerToken: token) { result in
             switch result {
             case .success(let transactionResponse):
                 // Handle successful transaction creation
                 print("Transaction created: \(transactionResponse)")
                 // Update UI or perform actions based on the successful transaction creation
                 
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
