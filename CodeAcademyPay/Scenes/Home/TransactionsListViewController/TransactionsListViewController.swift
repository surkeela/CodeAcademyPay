//
//  TransactionsListViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-02.
//

import UIKit

class TransactionsListViewController: UIViewController {
    @IBOutlet weak var transactionTableView: UITableView!
    var allTransactions: [Transaction] = []
    var currentUser: AuthenticatedUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        transactionTableView.dataSource = self
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        transactionTableView.register(nib, forCellReuseIdentifier: "TransactionTableViewCell")
    }

}

extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        
        if let amountString = allTransactions[indexPath.row].amount,
           let amount = Double(amountString) {
            let formattedAmount = String(format: "%.2f", amount)
            
            cell.amountLabel.text = formattedAmount
            cell.currencyLabel.text = allTransactions[indexPath.row].currency
            cell.dateLabel.text = allTransactions[indexPath.row].createdAt
            cell.noteLabel.text = allTransactions[indexPath.row].transactionDescription
            
            if allTransactions[indexPath.row].receiver == currentUser?.phoneNumber {
                cell.phoneNumberLabel.text = allTransactions[indexPath.row].sender
                cell.transactionTypeLabel.text = "+"
                cell.transactionTypeLabel.textColor = UIColor.green
            } else {
                cell.phoneNumberLabel.text = allTransactions[indexPath.row].receiver
                cell.transactionTypeLabel.text = "-"
                cell.transactionTypeLabel.textColor = UIColor.red
            }
        } else {
            cell.amountLabel.text = allTransactions[indexPath.row].currency
        }
        
        return cell
    }
}
