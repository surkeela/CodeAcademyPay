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
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var confirmPasswordTextField: UITextField!
    @IBOutlet weak private var currencyTextField: UITextField!
    @IBOutlet weak private var submitButton: UIButton!
    
    private let authenticationType: AuthenticationType
    private let viewModel = UserManagementViewModel()
    private var registeredUsers: [User] = []
    
    init(authenticationType: AuthenticationType) {
        self.authenticationType = authenticationType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchAllUsers()
        
        switch authenticationType {                 //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
        case .login:                                //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
            phoneNumberTextField.text = "862454343" //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
            passwordTextField.text = "123"          //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
        case .registration:                         //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
            currencyTextField.text = "EUR"          //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
        }
    }
    
    private func setupUI(showNameTextField: Bool, showConfirmPasswordTextField: Bool, showCurrencyTextField: Bool, buttonTitle: String) {
        nameTextField.isHidden = !showNameTextField
        confirmPasswordTextField.isHidden = !showConfirmPasswordTextField
        currencyTextField.isHidden = !showCurrencyTextField
        submitButton.setTitle(buttonTitle, for: .normal)
        navigationController?.navigationBar.tintColor = UIColor.white
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
        viewModel.getAllUsers(errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let users):
                self?.registeredUsers = users
            case .failure(let error):
                print("Failed to fetch users: \(error)")
            }
        }
    }
    
    private func performUserRegistration() {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text,
              !name.isEmpty, !password.isEmpty, !currency.isEmpty, !phoneNumber.isEmpty else {
            return
        }
        
        KeychainHelper.saveOrUpdateString(value: password, forKey: "Password")
        let userData = UserRegistrationData(name: name, password: password, currency: currency, phoneNumber: phoneNumber)
        
        viewModel.registerUser(userData: userData, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let registeredUser):
                print("User created successfully: \(registeredUser)")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                self?.performLoginAfterRegistration(phoneNumber: phoneNumber, password: password, id: registeredUser.id)
            case .failure(let error):
                print("Failed to create user: \(error)")
            }
        }
    }
    
    private func performLoginAfterRegistration(phoneNumber: String, password: String, id: String) {
        viewModel.loginUser(phoneNumber: phoneNumber, password: password, id: id, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }) { [weak self] result in
            switch result {
            case .success(let loginResponse):
                print("User logged in successfully: \(loginResponse)") //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                KeychainHelper.saveOrUpdateString(value: loginResponse.value, forKey: "Bearer_token")
                self?.viewModel.fetchDataWithBearerToken(userID: loginResponse.user.id, errorHandler: { errorMessage in
                    DispatchQueue.main.async {
                        self?.showErrorAlert(message: errorMessage)
                    }
                }) { [weak self] result in
                    switch result {
                    case .success(let authenticatedUser):
                        print("Fetched data: \(authenticatedUser)")  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                        DispatchQueue.main.async {
                            let homeViewController = HomeViewController(currentUser: authenticatedUser)
                            self?.navigationController?.pushViewController(homeViewController, animated: true)
                        }
                    case .failure(let error):
                        print("Failed to fetch data: \(error)")
                    }
                }
            case .failure(let error):
                print("Failed to log in user: \(error)")
            }
        }
    }
    
    private func performLogin() {
        guard let phoneNumber = phoneNumberTextField.text,
              let password = passwordTextField.text,
              !phoneNumber.isEmpty, !password.isEmpty else {
            showErrorAlert(message: "Please fill in all fields.")
            return
        }
        
        KeychainHelper.saveOrUpdateString(value: password, forKey: "Password")
        
        if let registeredUser = registeredUsers.first(where: { $0.phoneNumber == phoneNumber }) {
            performLoginAfterRegistration(phoneNumber: phoneNumber, password: password, id: registeredUser.id)
        } else {
            showErrorAlert(message: "No user found with the entered phone number.")
        }
    }
    
    private func validateRegistrationFields() -> Bool {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text else {
            return false
        }
        
        if !ValidationHelper.isValidPhoneNumber(phoneNumber) {
            showAlert(title: "Invalid Phone Number", message: "Phone number should be at least 9 digits long and consist of digits only.")
            return false
        }
        
        if !ValidationHelper.isValidCurrency(currency) {
            showAlert(title: "Invalid Currency", message: "Currency should consist of 3 uppercase letters.")
            return false
        }
        
        if name.isEmpty {
            showAlert(title: "Invalid Name", message: "Name field cannot be empty.")
            return false
        }
        
        if password.count < 3 || password != confirmPassword {
            showAlert(title: "Invalid Password", message: "Password should be at least 3 characters long and match the confirmation.")
            return false
        }
        
        return true
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        switch authenticationType {
        case .login:
            performLogin()
        case .registration:
            if !validateRegistrationFields() { return }
            performUserRegistration()
        }
    }
    
}
