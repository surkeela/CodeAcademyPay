//
//  HomeViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-26.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    private let transactionViewModel = TransactionViewModel()
    private var currentUser: AuthenticatedUser
    private var allTransactions: [Transaction] = []
    
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
        fetchTransactions()
        fetchTransactionsForUser(userID: currentUser.id)
        setupUI()
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
    
   private func fetchTransactions() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else { return }
        let userID = currentUser.id
        
        transactionViewModel.fetchAllTransactions(bearerToken: token, userID: userID, errorHandler: { errorMessage in
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
            }
        }, completion: { result in
            switch result {
            case .success(let transactions):
                DispatchQueue.main.async {
                    self.saveTransactionsToCoreData(transactionResponses: transactions, currentUserID: self.currentUser.id)
                    //                    self.transactionTableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch transactions: \(error)")
            }
        })
    }
    
   private func saveTransactionsToCoreData(transactionResponses: [TransactionResponse], currentUserID: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for transactionResponse in transactionResponses {
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", transactionResponse.id)
            
            do {
                if let existingTransaction = try context.fetch(fetchRequest).first {
                    existingTransaction.update(with: transactionResponse)
                } else {
                    let newTransaction = Transaction(context: context)
                    newTransaction.update(with: transactionResponse)
                    newTransaction.userResponseId = transactionResponse.user.id
                }
            } catch {
                print("Error during fetch or update in Core Data")
            }
        }
        
        do {
            try context.save()
            print("Successfully saved to Core Data")
        } catch {
            print("Error during save to Core Data")
        }
    }
    
   private func fetchTransactionsForUser(userID: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userResponseId == %@", userID)
        
        do {
            let transactions = try context.fetch(fetchRequest)
            allTransactions = transactions
            transactionTableView.reloadData()
        } catch {
            print("Error fetching transactions for user \(userID): \(error)")
        }
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
//        let receivedTransactions = allTransactions.filter { $0.receiver == currentUser.phoneNumber }
        let count = min(allTransactions.count, 5)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        
        let reversedTransactions = Array(allTransactions.reversed())
        
        cell.amountLabel.text = reversedTransactions[indexPath.row].amount
        cell.currencyLabel.text = reversedTransactions[indexPath.row].currency
        cell.dateLabel.text = reversedTransactions[indexPath.row].createdAt
        cell.noteLabel.text = reversedTransactions[indexPath.row].transactionDescription
        
        if reversedTransactions[indexPath.row].receiver == currentUser.phoneNumber {
            cell.phoneNumberLabel.text = reversedTransactions[indexPath.row].sender
            cell.transactionTypeLabel.text = "+"
            cell.transactionTypeLabel.textColor = UIColor.green
        } else {
            cell.phoneNumberLabel.text = reversedTransactions[indexPath.row].receiver
            cell.transactionTypeLabel.text = "-"
            cell.transactionTypeLabel.textColor = UIColor.red
        }
        
        return cell
    }
}
