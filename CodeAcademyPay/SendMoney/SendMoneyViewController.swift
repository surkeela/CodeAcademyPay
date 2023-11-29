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
    var currentUser: AuthenticatedUser?
    var transactionHandler: ((Double) -> Void)?
    
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var sumTextField: UITextField!
    @IBOutlet weak private var noteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllUsers()
        configureUI()
        print("🟢Current User:\(currentUser.debugDescription)")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
    }
    
    private func configureUI() {
        guard let userBalance = currentUser?.balance else { return }
        balanceLabel.text = String(describing: userBalance)
        currencyLabel.text = currentUser?.currency
        sumTextField.delegate = self
        noteTextField.delegate = self
    }
    
    private func fetchAllUsers() {
        userViewModel.getAllUsers(errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                print("Failed to fetch users: \(error)")
            }
        }
    }
    
    private func findRecipient(by phoneNumber: String) -> User? {
        return users.first { $0.phoneNumber == phoneNumber }
    }
    
    private func sendMoney() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else {
            print("Token not found in UserDefaults")
            return
        }
        
        guard let receiverPhoneNumber = phoneNumberTextField.text,
              let amount = sumTextField.text,
              let currency = currentUser?.currency,
              let transactionAmount = Double(amount),
              !receiverPhoneNumber.isEmpty, transactionAmount > 0 else {
            showErrorAlert(message: "Please enter valid details for sending money.")
            return
        }
        
        if let recipientUser = findRecipient(by: receiverPhoneNumber) {
            guard currentUser?.currency == recipientUser.currency else {
                print("Currencies do not match")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                showErrorAlert(message: "The sending currency does not match the recipient's currency")
                return
            }
        } else {
            showErrorAlert(message: "Recipient not found with the entered phone number.")
        }
        
        let description = noteTextField.text ?? ""
        
        transactionViewModel.createTransaction(receiver: receiverPhoneNumber, amount: amount, currency: currency, description: description, bearerToken: token, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let transactionResponse):
                guard let transactionAmount = Double(transactionResponse.amount),
                      let currentBalance = self?.currentUser?.balance else {
                    return
                }
                let updatedBalance = currentBalance - transactionAmount
                print("Transaction created: \(transactionResponse)")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                DispatchQueue.main.async {
                    self?.transactionHandler?(updatedBalance)
                    self?.phoneNumberTextField.text = ""
                    self?.sumTextField.text = ""
                    self?.noteTextField.text = ""
                    self?.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print("Transaction creation failed: \(error)")
            }
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        sendMoney()
    }
    
}

extension SendMoneyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMoney()
        return true
    }
}
