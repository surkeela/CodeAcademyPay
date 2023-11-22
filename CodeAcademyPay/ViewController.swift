//
//  ViewController.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import UIKit

class ViewController: UIViewController {
    
//    let authenticationManager = AuthenticationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        let authenticationViewController = AuthenticationViewController(authenticationType: .login)
        navigationController?.pushViewController(authenticationViewController, animated: true)
    }
    
    @IBAction func registerButtonTaped(_ sender: Any) {
        let authenticationViewController = AuthenticationViewController(authenticationType: .registration)
        navigationController?.pushViewController(authenticationViewController, animated: true)
    }
    
}

