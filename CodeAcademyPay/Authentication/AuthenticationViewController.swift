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
    let authenticationManager = AuthenticationManager()
    var registeredUsers: [User] = []

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
//        getRegisteredUsers()
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
    
//    private func getRegisteredUsers() {
//        viewModel.getAllUsers { [weak self] result in
//            switch result {
//            case .success(let users):
//                self?.registeredUsers = users
//                for user in users { 
//                    print(user)
//                }
//            case .failure(let error):
//                print("Failed to retrieve users: \(error)")
//            }
//        }
//    }
    
    private func performUserRegistration() {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text,
              !name.isEmpty, !password.isEmpty, !currency.isEmpty, !phoneNumber.isEmpty else {
            print("One or more text fields are empty")
            return
        }
        
        let userData = UserRegistrationData(name: name, password: password, currency: currency, phoneNumber: phoneNumber)
        
        viewModel.registerUser(userData: userData) { [weak self] result in
            switch result {
            case .success(let user):
                print("User created successfully: \(user)")
                self?.viewModel.fetchAuthenticatedUser(userID: user.id, authToken: "h0WEhyyHGLKbjrKcZ4v73g==") { result in
                    switch result {
                    case .success(let authenticatedUser):
                        print("Authenticated user details: \(authenticatedUser)")
                    case .failure(let error):
                        print("Failed to fetch authenticated user: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to create user: \(error)")
            }
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        performUserRegistration()
    }
    
}
