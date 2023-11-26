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
        fetchAllUsers()
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
    
    private func fetchAllUsers() {
        viewModel.getAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.registeredUsers = users
            case .failure(let error):
                // Handle the failure to fetch users
                print("Failed to fetch users: \(error)")
                // Show an alert or update UI to inform the user about the error
            }
        }
    }
    
    private func performUserRegistration() {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text,
              !name.isEmpty, !password.isEmpty, !currency.isEmpty, !phoneNumber.isEmpty else {
            // Handle empty text fields or any other validation failure
            // Show an alert or update UI to inform the user about the missing fields
            return
        }
        
        let userData = UserRegistrationData(name: name, password: password, currency: currency, phoneNumber: phoneNumber)
        
        viewModel.registerUser(userData: userData) { [weak self] result in
            switch result {
            case .success(let registeredUser):
                print("User created successfully: \(registeredUser)")
                self?.performLoginAfterRegistration(phoneNumber: phoneNumber, password: password, id: registeredUser.id)
                // Optionally, you might inform the user about successful registration
                // Show an alert or update UI indicating successful registration
            case .failure(let error):
                print("Failed to create user: \(error)")
                // Inform the user about registration failure
                // Show an alert or update UI indicating registration failure
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
                    case .success(let authenticatedUser):
                        print("Fetched data: \(authenticatedUser)")
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
    
    private func performLogin() {
        guard let phoneNumber = phoneNumberTextField.text,
              let password = passwordTextField.text,
              !phoneNumber.isEmpty, !password.isEmpty else {
            // Handle empty text fields or any other validation failure
            // Show an alert or update UI to inform the user about missing fields
            return
        }

        // Check if there's an authenticated user with the entered phone number
        if let registeredUser = registeredUsers.first(where: { $0.phoneNumber == phoneNumber }) {
            print(registeredUser.id)
            performLoginAfterRegistration(phoneNumber: phoneNumber, password: password, id: registeredUser.id)
        } else {
            // Handle scenario when no matching authenticated user is found
            // Show an alert or update UI to inform the user about the absence of an authenticated user
            print("No authenticated user found with the entered phone number.")
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        switch authenticationType {
        case .login:
            performLogin()
        case .registration:
            performUserRegistration()
        }
    }
    
}
