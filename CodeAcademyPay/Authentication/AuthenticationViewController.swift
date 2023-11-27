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
    
    private let authenticationType: AuthenticationType
    private let viewModel = UserManagementViewModel()
    private var registeredUsers: [User] = []
    private var token = ""

    init(authenticationType: AuthenticationType) {
        self.authenticationType = authenticationType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak private var nameTextField: UITextField!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var passwordTextField: UITextField!
    @IBOutlet weak private var confirmPasswordTextField: UITextField!
    @IBOutlet weak private var currencyTextField: UITextField!
    @IBOutlet weak private var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchAllUsers()
        
        switch authenticationType {   //////////////////////////////////////////
        case .login:   //////////////////////////////////////////
            phoneNumberTextField.text = "862454341"   //////////////////////////////////////////
            passwordTextField.text = "nnn"   //////////////////////////////////////////
        case .registration:
            currencyTextField.text = "EUR"   //////////////////////////////////////////
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
            case .success(let loginResponse):
                self?.token = loginResponse.value
                print("User logged in successfully: \(loginResponse)")
                UserDefaults.standard.set(loginResponse.value, forKey: "UserToken")
                self?.viewModel.fetchDataWithBearerToken(userID: loginResponse.user.id, bearerToken: loginResponse.value) { [weak self] result in
                    switch result {
                    case .success(let authenticatedUser):
                        print("Fetched data: \(authenticatedUser)")
                        DispatchQueue.main.async {
                            let homeViewController = HomeViewController(currentUser: authenticatedUser)
                            self?.navigationController?.pushViewController(homeViewController, animated: true)
                        }
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
            showAlert(title: "Error", message: "Please fill in all fields.")
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
    
    private func validateRegistrationFields() -> Bool {
        guard let name = nameTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              let currency = currencyTextField.text,
              let phoneNumber = phoneNumberTextField.text else {
            return false
        }
        
        // Regular expressions for validation
        let phoneNumberRegex = #"^\d{9,}$"#
        let currencyRegex = #"^[A-Z]{3}$"#
        
        // Validation checks
        let phoneNumberIsValid = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: phoneNumber)
        let currencyIsValid = NSPredicate(format: "SELF MATCHES %@", currencyRegex).evaluate(with: currency)
        let nameIsValid = !name.isEmpty
        let passwordIsValid = password.count >= 3 && password == confirmPassword
        
        if !phoneNumberIsValid {
            showAlert(title: "Invalid Phone Number", message: "Phone number should be at least 9 digits long and consist of digits only.")
            return false
        }
        
        if !currencyIsValid {
            showAlert(title: "Invalid Currency", message: "Currency should consist of 3 uppercase letters.")
            return false
        }
        
        if !nameIsValid {
            showAlert(title: "Invalid Name", message: "Name field cannot be empty.")
            return false
        }
        
        if !passwordIsValid {
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
            if !validateRegistrationFields() {
                // Handle invalid fields (show alerts, update UI, etc.)
                return
            }
            performUserRegistration()
        }
    }
    
//    func handleError(_ error: Error) {
//       if let apiError = error as? APIError, apiError.error {
//           showAlert(title: "Error", message: apiError.reason)
//       } else {
//           showAlert(title: "Error", message: "An unknown error occurred.")
//       }
//   }
    
}
