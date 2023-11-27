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
    var users: [User] = []
    var currentUser: AuthenticatedUser
    
    init(currentUser: AuthenticatedUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak private var balanceLabel: UILabel!
    @IBOutlet weak private var transactionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        transactionTableView.layer.cornerRadius = 20
        balanceLabel.text = String(currentUser.balance)
    }

    @IBAction func addMoneyTapped(_ sender: Any) {
    }
    
    @IBAction func sendMoneyTapped(_ sender: Any) {
        let sendMoneyViewController = SendMoneyViewController()
        present(sendMoneyViewController, animated: true, completion: nil)
//        navigationController?.pushViewController(sendMoneyViewController, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
    }
}
