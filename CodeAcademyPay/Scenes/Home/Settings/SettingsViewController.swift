//
//  SettingsViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-03.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak private var newPasswordTextField: UITextField!
    @IBOutlet weak private var newCurrencyTextField: UITextField!
    
    private let userViewModel = UserManagementViewModel()
    var currentUser: AuthenticatedUser?
    
    var onCurrencyUpdate: ((String) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func updatePassword() {
        guard let newPassword = newPasswordTextField.text,
              let name = currentUser?.name,
              let currency = currentUser?.currency,
              !newPassword.isEmpty else {
            showErrorAlert(message: "Field cannot be empty")
            return
        }
        
        userViewModel.updateUserAuth(name: name, password: newPassword, currency: currency, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }, completion: { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.newPasswordTextField.text = nil
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    private func updateCurrency() {
        guard let name = currentUser?.name,
              let newCurrency = newCurrencyTextField.text,
              !newCurrency.isEmpty else {
            showErrorAlert(message: "Field cannot be empty")
            return
        }
        
        if !ValidationHelper.isValidCurrency(newCurrency) {
            showAlert(title: "Invalid Currency", message: "Currency should consist of 3 uppercase letters.")
            return
        }
        
        guard let newPassword = KeychainHelper.getStringFromKeychain(forKey: "Password") else { return }
        
        userViewModel.updateUserAuth(name: name, password: newPassword, currency: newCurrency, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }, completion: { [weak self] result in
            switch result {
            case .success(let updatedUser):
                DispatchQueue.main.async {
                    self?.onCurrencyUpdate?(updatedUser.currency)
                    self?.newCurrencyTextField.text = nil
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        updatePassword()
    }
    
    @IBAction func updateCurrencyTapped(_ sender: Any) {
        updateCurrency()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
