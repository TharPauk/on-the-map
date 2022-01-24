//
//  LoginViewController.swift
//  On the Map
//
//  Created by Min Thet Maung on 29/04/2021.
//

import UIKit

class LoginViewController: UIViewController {

    
    // MARK: - IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let username = emailTextField.text,
              username.count > 0,
              let password = passwordTextField.text,
              password.count > 0 else {
            self.showMessage(title: "Login Fail", message: "Username or password should not be empty.")
            return
        }
        setLoggingIn(isLoggingIn: true)
        APIClient.createSession(username: username, password: password, completion: handleCreateSession(success:error:))
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let app = UIApplication.shared
        let urlString = APIClient.Endpoints.signUpUrl
        
        if let url = URL(string: urlString) {
            app.openURL(url)
        }
    }
    
    
    
    // MARK: - Helper Functions
    
    private func handleCreateSession(success: Bool, error: Error?) {
        if success {
            performSegue(withIdentifier: "loginSuccess", sender: nil)
            emailTextField.text = ""
            passwordTextField.text = ""
        } else {
            showMessage(title: "Login Fail", message: "Username or password is not correct.")
        }
        setLoggingIn(isLoggingIn: false)
    }
    
    private func setLoggingIn(isLoggingIn: Bool) {
        if isLoggingIn {
            activityView.startAnimating()
        } else {
            activityView.stopAnimating()
        }
        
        [emailTextField, passwordTextField, loginButton, signUpButton].forEach{ $0?.isEnabled = !isLoggingIn }
    }
    
}
