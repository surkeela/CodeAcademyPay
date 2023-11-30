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
        phoneNumberTextField.delegate = self
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
    
    private func initiateTransaction(receiverPhoneNumber: String, amount: String, currency: String, description: String, token: String) {
        transactionViewModel.createTransaction(receiver: receiverPhoneNumber, amount: amount, currency: currency, description: description, bearerToken: token, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let transactionResponse):
                self?.handleTransactionSuccess(transactionResponse: transactionResponse)
            case .failure(let error):
                print("Transaction creation failed: \(error)")
            }
        }
    }
    
    private func handleTransactionSuccess(transactionResponse: TransactionResponse) {
        guard let transactionAmount = Double(transactionResponse.amount),
              let currentBalance = self.currentUser?.balance else {
            return
        }
        let updatedBalance = currentBalance - transactionAmount
        print("Transaction created: \(transactionResponse)")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
        DispatchQueue.main.async {
            self.transactionHandler?(updatedBalance)
            self.phoneNumberTextField.text = ""
            self.sumTextField.text = ""
            self.noteTextField.text = ""
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func sendMoney() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else {
            print("Token not found in UserDefaults")
            return
        }
        
        guard let receiverPhoneNumber = phoneNumberTextField.text,
              let amount = sumTextField.text,
              let currency = currentUser?.currency,
              !receiverPhoneNumber.isEmpty else {
            showErrorAlert(message: "Fields cannot be empty")
            return
        }
        
        guard receiverPhoneNumber != currentUser?.phoneNumber else {
            showErrorAlert(message: "You cannot send money to yourself.")
            return
        }
        
        if let recipientUser = findRecipient(by: receiverPhoneNumber) {
            guard currentUser?.currency == recipientUser.currency else {
                showErrorAlert(message: "The sending currency does not match the recipient's currency")
                return
            }
        } else {
            showErrorAlert(message: "Recipient not found with the entered phone number.")
            return
        }
        
        let description = noteTextField.text ?? ""
        initiateTransaction(receiverPhoneNumber: receiverPhoneNumber, amount: amount, currency: currency, description: description, token: token)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == sumTextField {
            return validateSumTextFieldChange(textField: textField, range: range, replacementString: string)
        }
        return true
    }

    private func validateSumTextFieldChange(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }

        guard let text = textField.text, let range = Range(range, in: text) else {
            return true
        }

        let updatedText = text.replacingCharacters(in: range, with: string)
        let formatter = NumberFormatter()
        formatter.allowsFloats = true

        if let number = formatter.number(from: updatedText), let decimalSeparator = formatter.decimalSeparator {
            let decimalPlaces = updatedText.components(separatedBy: decimalSeparator)

            if decimalPlaces.count == 2, let lastDecimal = decimalPlaces.last, lastDecimal.count > 2 {
                return false
            }
            return number.doubleValue >= 0
        }
        return false
    }
    
}
