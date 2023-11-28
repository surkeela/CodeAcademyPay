//
//  pavizdys.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import UIKit

class Pavizdys: UIViewController {
    
    let userViewModel = UserManagementViewModel()
    var users: [User] = []
    let actionClosure: (UIAction) -> Void = { action in
        print(action.title)
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllUsers()
        configureUI()
    }
    
    private func configureUI() {
        var menuChildren: [UIMenuElement] = []
        let chooseAction = UIAction(title: "Select a recipient", handler: actionClosure)
        menuChildren.append(chooseAction)
        
        for user in users {
            menuChildren.append(UIAction(title: user.name, handler: actionClosure))
        }
        
        button.menu = UIMenu(options: .displayInline, children: menuChildren)
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        
//        UIMenuController.shared.arrowDirection = .down
    }
    
    private func fetchAllUsers() {
        userViewModel.getAllUsers(errorHandler: { errorMessage in
            // Show an alert or update UI to inform the user about the error
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
                // Update UI with fetched users
                DispatchQueue.main.async {
                    // Update UI elements or trigger UI refresh
                    // For example:
                   // self?.tableView.reloadData()
                }
            case .failure(let error):
                // Handle the failure to fetch users
                print("Failed to fetch users: \(error)")
                // Show an alert or update UI to inform the user about the error
            }
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        textField.becomeFirstResponder()
    }
    
}
