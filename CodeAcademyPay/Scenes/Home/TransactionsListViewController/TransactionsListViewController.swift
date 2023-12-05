//
//  TransactionsListViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-02.
//

import UIKit

enum SortBy {
    case date
    case amount
    case currency
    case transactionType
}

class TransactionsListViewController: UIViewController {
    @IBOutlet private weak var transactionTableView: UITableView!
    @IBOutlet private weak var transactionsSearchBar: UISearchBar!
    @IBOutlet private weak var filterButton: UIButton!
    
    var allTransactions: [Transaction] = []
    var currentUser: AuthenticatedUser?
    
    var filteredTransactions: [Transaction] = [] {
        didSet {
            transactionTableView.reloadData()
        }
    }
    
    var sortBy: SortBy = .date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        transactionTableView.dataSource = self
        transactionTableView.delegate = self
        transactionsSearchBar.delegate = self
        let nib = UINib(nibName: "TransactionTableViewCell", bundle: nil)
        transactionTableView.register(nib, forCellReuseIdentifier: "TransactionTableViewCell")
        filteredTransactions = allTransactions
        filterButton.menu = menu
        filterButton.showsMenuAsPrimaryAction = true
        filterButton.layer.cornerRadius = 8
        navigationItem.title = "Transactions"
    }
    
    lazy var menu: UIMenu = {
        let dateAction = UIAction(title: "By date") { [weak self] _ in
            self?.sortBy(.date)
        }
        let amountAction = UIAction(title: "By amount") { [weak self] _ in
            self?.sortBy(.amount)
        }
        let currencyAction = UIAction(title: "By currency") { [weak self] _ in
            self?.sortBy(.currency)
        }
        let transactionTypeAction = UIAction(title: "By transaction type") { [weak self] _ in
            self?.sortBy(.transactionType)
        }
        
        return UIMenu(title: "Sort", children: [dateAction, amountAction, currencyAction, transactionTypeAction])
    }()
    
    func sortBy(_ sortType: SortBy) {
        self.sortBy = sortType
        
        switch sortType {
        case .date:
            filteredTransactions.sort {
                guard let firstDate = $0.createdAt, let secondDate = $1.createdAt else { return false }
                return firstDate < secondDate
            }
        case .amount:
            filteredTransactions.sort {
                guard let firstAmount = Double($1.amount ?? "1"), let secondAmount = Double($0.amount ?? "0") else { return false }
                return firstAmount < secondAmount
            }
        case .currency:
            filteredTransactions.sort {
                return $0.currency ?? "" < $1.currency ?? ""
            }
        case .transactionType:
            filteredTransactions.sort {
                guard let currentUserPhone = self.currentUser?.phoneNumber else { return false }
                let isOutgoing1 = $0.sender == currentUserPhone
                let isOutgoing2 = $1.sender == currentUserPhone
                return isOutgoing1 == isOutgoing2 ? $0.createdAt ?? "" < $1.createdAt ?? "" : isOutgoing1
            }
        }
        
        transactionTableView.reloadData()
    }
}

extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell", for: indexPath) as! TransactionTableViewCell
        
        if let amountString = filteredTransactions[indexPath.row].amount {
            let formattedAmount = ValidationHelper.formatAmountString(amountString)
            
            cell.amountLabel.text = formattedAmount
            cell.currencyLabel.text = filteredTransactions[indexPath.row].currency
            cell.dateLabel.text = filteredTransactions[indexPath.row].createdAt
            cell.noteLabel.text = filteredTransactions[indexPath.row].transactionDescription
            
            if filteredTransactions[indexPath.row].receiver == currentUser?.phoneNumber {
                cell.phoneNumberLabel.text = filteredTransactions[indexPath.row].sender
                cell.transactionTypeLabel.text = "+"
                cell.transactionTypeLabel.textColor = UIColor.green
            } else {
                cell.phoneNumberLabel.text = filteredTransactions[indexPath.row].receiver
                cell.transactionTypeLabel.text = "-"
                cell.transactionTypeLabel.textColor = UIColor.red
            }
        } else {
            cell.amountLabel.text = filteredTransactions[indexPath.row].currency
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTransaction = filteredTransactions[indexPath.row]
        
        guard let currentUserPhone = currentUser?.phoneNumber else { return }
        
        if selectedTransaction.sender == currentUserPhone {
            let sendMoneyViewController = SendMoneyViewController()
            sendMoneyViewController.selectedTransaction = selectedTransaction
            navigationController?.pushViewController(sendMoneyViewController, animated: true)
        } else {
        }
    }
    
}

extension TransactionsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredTransactions = searchText.isEmpty ? allTransactions :
        allTransactions.filter { transaction in
            return transaction.matchesSearchQuery(searchText)
        }
        
        transactionTableView.reloadData()
    }
}
