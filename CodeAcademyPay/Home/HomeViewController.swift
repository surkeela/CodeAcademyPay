//
//  HomeViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-26.
//

import UIKit

class HomeViewController: UIViewController {
    private let transactionViewModel = TransactionViewModel()
    private var currentUser: AuthenticatedUser
    private var allTransactions: [TransactionResponse] = []
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTransactions()
    }
    
    private func setupUI() {
        navigationItem.hidesBackButton = true
        transactionTableView.layer.cornerRadius = 25
        balanceLabel.text = String(currentUser.balance)
        transactionTableView.dataSource = self
        transactionTableView.delegate = self
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        transactionTableView.register(nib, forCellReuseIdentifier: "TransactionTableViewCell")
    }
    
    func fetchTransactions() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else { return }
        let userID = currentUser.id

        transactionViewModel.fetchAllTransactions(bearerToken: token, userID: userID, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
            print(errorMessage)  //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
        }, completion: { result in
            switch result {
            case .success(let transactionResponse):
                DispatchQueue.main.async {
                    self.allTransactions = transactionResponse
                }
                for transaction in transactionResponse {
                    print("🟢Received transactions: \(transaction)🟢") //⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️//
                    print("🦄\(transaction.receiver)🦄")
                }
            case .failure(let error):
                print("Failed to fetch transactions: \(error)")
            }
        })
    }

    @IBAction func addMoneyTapped(_ sender: Any) {
    }
    
    @IBAction func sendMoneyTapped(_ sender: Any) {
        let sendMoneyViewController = SendMoneyViewController()
        sendMoneyViewController.currentUser = currentUser
        sendMoneyViewController.transactionHandler = { updatedBalance in
            self.balanceLabel.text = "\(updatedBalance)"
            self.currentUser.balance = updatedBalance
        }
        present(sendMoneyViewController, animated: true, completion: nil)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        
        return cell
    }
}

