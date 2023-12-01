//
//  UnderlinedTextField.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import UIKit

class UnderlinedTextField: UITextField {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.systemMint.cgColor
        
        self.layer.addSublayer(bottomLine)
    }
}
