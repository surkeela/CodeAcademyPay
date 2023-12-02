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
    var currentUser: AuthenticatedUser?
    var transactionCompletionHandler: ((Double) -> Void)?
    
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var currencyLabel: UILabel!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var sumTextField: UITextField!
    @IBOutlet weak private var noteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentUserBalance()
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
  
    private func fetchCurrentUserBalance() {
        guard let userId = currentUser?.id else { return }
        
        userViewModel.fetchUserBalance(userID: userId) { [weak self] result in
            switch result {
            case .success(let balance):
                DispatchQueue.main.async {
                    self?.updateBalanceLabel(balance)
                }
            case .failure(let error):
                print("Failed to fetch user balance: \(error)")
            }
        }
    }

    private func updateBalanceLabel(_ balance: Double) {
        balanceLabel.text = String(format: "%.2f", balance)
    }
    
    private func initiateTransaction(receiverPhoneNumber: String, amount: String, currency: String, description: String?) {
        transactionViewModel.createTransaction(receiver: receiverPhoneNumber, amount: amount, currency: currency, description: description, errorHandler: { [weak self] error in
                DispatchQueue.main.async {
                    self?.showErrorAlert(message: error)
                }
            },
            completion: { [weak self] result in
                switch result {
                case .success(let transactionResponse):
                    self?.handleTransactionSuccess(transactionResponse)
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        )
    }

    private func handleTransactionSuccess(_ transactionResponse: TransactionResponse) {
        guard let transactionAmount = Double(transactionResponse.amount),
              let currentBalance = self.currentUser?.balance else {
            return
        }
        
        let updatedBalance = currentBalance - transactionAmount
        DispatchQueue.main.async {
            self.transactionCompletionHandler?(updatedBalance)
            self.clearTextFields()
            self.dismiss(animated: true, completion: nil)
        }
    }

    private func clearTextFields() {
        phoneNumberTextField.text = nil
        sumTextField.text = nil
        noteTextField.text = nil
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        guard let receiverPhoneNumber = phoneNumberTextField.text,
              let amount = sumTextField.text,
              let currency = currentUser?.currency else {
            showErrorAlert(message: "Fields cannot be empty")
            return
        }
        
        guard receiverPhoneNumber != currentUser?.phoneNumber else {
            showErrorAlert(message: "You cannot send money to yourself.")
            return
        }

        let description = noteTextField.text
        initiateTransaction(receiverPhoneNumber: receiverPhoneNumber, amount: amount, currency: currency, description: description)
    }
    
}

extension SendMoneyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendTapped(textField)
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
