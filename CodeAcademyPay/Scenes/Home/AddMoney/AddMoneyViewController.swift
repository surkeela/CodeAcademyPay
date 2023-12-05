//
//  AddMoneyViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-01.
//

import UIKit

class AddMoneyViewController: UIViewController {
    @IBOutlet weak private var currencyTextField: UnderlinedTextField!
    @IBOutlet weak private var amountTextField: UnderlinedTextField!
    
    private let transactionViewModel = TransactionViewModel()
    var currentUser: AuthenticatedUser?
    var addMoneyCompletionHandler: ((Double) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyTextField.delegate = self
        amountTextField.delegate = self
    }
    
    private func performAddMoneyTransaction() {
        guard let amount = amountTextField.text,
              let currency = currencyTextField.text else {
            showErrorAlert(message: "Fields cannot be empty")
            return
        }
        
        guard let currentBalance = self.currentUser?.balance,
              let sendingAmount = Double(amount) else {
            return
        }
        
        let updatedBalance = currentBalance + sendingAmount
        let uppercasedCurrency = currency.uppercased()
        
        transactionViewModel.addMoneyTransaction(amount: amount, currency: uppercasedCurrency, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }, completion: { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.addMoneyCompletionHandler?(updatedBalance)
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    @IBAction func addTapped(_ sender: Any) {
        performAddMoneyTransaction()
    }
    
}

extension AddMoneyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addTapped(textField)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTextField {
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
