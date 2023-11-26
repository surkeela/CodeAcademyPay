//
//  AuthenticationViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import UIKit

enum AuthenticationType {
    case login
    case registration
}

class AuthenticationViewController: UIViewController {
    
    let authenticationType: AuthenticationType
    let viewModel = UserManagementViewModel()

    init(authenticationType: AuthenticationType) {
        self.authenticationType = authenticationType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func setupUI(showNameTextField: Bool, showConfirmPasswordTextField: Bool, showCurrencyTextField: Bool, buttonTitle: String) {
        nameTextField.isHidden = !showNameTextField
        confirmPasswordTextField.isHidden = !showConfirmPasswordTextField
        currencyTextField.isHidden = !showCurrencyTextField
        submitButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func configureUI() {
        switch authenticationType {
        case .login:
            setupUI(showNameTextField: false, showConfirmPasswordTextField: false, showCurrencyTextField: false, buttonTitle: "Login")
        case .registration:
            setupUI(showNameTextField: true, showConfirmPasswordTextField: true, showCurrencyTextField: true, buttonTitle: "Register")
        }
    }
    
    private func performUserRegistration() {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text,
              !name.isEmpty, !password.isEmpty, !currency.isEmpty, !phoneNumber.isEmpty else { return }
        
        let userData = UserRegistrationData(name: name, password: password, currency: currency, phoneNumber: phoneNumber)
        
        viewModel.registerUser(userData: userData) { [weak self] result in
            switch result {
            case .success(let user):
                print("User created successfully: \(user)")
                self?.performLoginAfterRegistration(phoneNumber: phoneNumber, password: password, id: user.id)
            case .failure(let error):
                print("Failed to create user: \(error)")
            }
        }
    }
    
    private func performLoginAfterRegistration(phoneNumber: String, password: String, id: String) {
        viewModel.loginUser(phoneNumber: phoneNumber, password: password, id: id) { [weak self] result in
            switch result {
            case .success(let user):
                print("User logged in successfully: \(user)")
                self?.viewModel.fetchDataWithBearerToken(userID: user.user.id, bearerToken: user.value) { result in
                    switch result {
                    case .success(let fetchedData):
                        print("Fetched data: \(fetchedData)")
                        // Handle the fetched data here
                    case .failure(let error):
                        print("Failed to fetch data: \(error)")
                        // Handle the failure case here
                    }
                }
            case .failure(let error):
                print("Failed to log in user: \(error)")
                // Handle login failure, maybe show an error to the user
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        performUserRegistration()
    }
    
}
