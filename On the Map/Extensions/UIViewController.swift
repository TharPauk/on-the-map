//
//  UIViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 30/04/2021.
//

import UIKit

extension UIViewController {
    
    // This method is to show alert message to the screen
    func showMessage(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(action)
        self.present(alertVC, animated: true)
    }
    
}
