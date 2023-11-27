//
//  HomeViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-26.
//

import UIKit

class HomeViewController: UIViewController {
    
//    let viewModel = TransactionViewModel()
//    let userViewModel = UserManagementViewModel()
    let token: String
    var users: [User] = []
    
    init(token: String) {
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var transactionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchAllUsers()
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        transactionTableView.layer.cornerRadius = 20
        print("Token:\(token)")
    }
    
//    private func fetchAllUsers() {
//        userViewModel.getAllUsers { [weak self] result in
//            switch result {
//            case .success(let users):
//                self?.users = users
//            case .failure(let error):
//                // Handle the failure to fetch users
//                print("Failed to fetch users: \(error)")
//                // Show an alert or update UI to inform the user about the error
//            }
//        }
//    }

    @IBAction func addMoneyTapped(_ sender: Any) {
    }
    
    @IBAction func sendMoneyTapped(_ sender: Any) {
//        sendMoney()
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
    }
}
