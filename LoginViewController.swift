//
//  LoginViewController.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 03/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit
import SafariServices


class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var panToClose: InteractionPanToClose!
    

    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        panToClose.setGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        
        showActivityIndicator(activityIndicator)
        
      if emailField.text!.isEmpty != false && passwordField.text!.isEmpty != false {
            displayAlert(title: "Login Unsuccessful", message: "Username and/or Password is empty")
        } else {
            UdacityClient.sharedInstance().authenticateUser(username: emailField.text!, password: passwordField.text!) { (success, errorString) in
                executeOnMain {
                    
                    self.hideActivityIndicator(uiView: self.activityIndicator)
                    
                    if success{
                        executeOnMain {
                            self.completeTheLogin()
                            print("Successfully logged in!")
                        }
                    } else if errorString != nil {
                        executeOnMain {
                            self.displayAlert(title: "Login Unsuccessful", message: errorString)
                        }
                    } else {
                        executeOnMain {
                            self.displayAlert(title: "Login Unsuccessful", message: "Invalid Username and/or Password")
                        }
                    }
                }
            }
        }
    }
    
    private func completeTheLogin() {
        //self.performSegue(withIdentifier: "goToMainScreenSegue", sender: nil)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapTabBar")
        self.present(controller, animated: true, completion: nil) 
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        
            if let url = URL(string: "https://in.udacity.com/auth#signup") {
            let svc = SFSafariViewController(url: url)
            self.present(svc, animated: true, completion: nil)
        }
    }
    
    ////////
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Keyboard Methods
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        view.frame.origin.y = -(getKeyboardHeight(notification))
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }
    ///////////////
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    /////////////
    func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    
    func hideActivityIndicator(uiView: UIView) {
        DispatchQueue.main.async {
            if let viewWithTag = uiView.viewWithTag(789456123) {
                viewWithTag.removeFromSuperview()
            }
            else {
                return
            }
        }
    }
}











/* import Foundation
import SafariServices
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    /* func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView){
     self.activityIndicator.stopAnimating()
     UIApplication.shared.endIgnoringInteractionEvents()
     } */
    
    func hideActivityIndicator(uiView: UIView) {
        DispatchQueue.main.async {
            if let viewWithTag = uiView.viewWithTag(789456123) {
                viewWithTag.removeFromSuperview()
            }
            else {
                return
            }
        }
    }
    
    
   
    
    @IBAction func signupPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://auth.udacity.com/sign-up")! as URL, options: [:], completionHandler: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        showActivityIndicator(activityIndicator)
        
        if emailField.text!.isEmpty != false && passwordField.text!.isEmpty != false{
            _ = UIAlertController(title: "Incomplete Form", message: "Please fill out all fields", preferredStyle: .alert)}
            else {
                UdacityClient.sharedInstance().authenticateUser(username: emailField.text!, password: passwordField.text!) { (success, errorString) in
                    
                    self.hideActivityIndicator(uiView: self.activityIndicator)
                    
                           if success{
                             self.loginCompletion()
                            }
                        if errorString != nil {
                            
                                _ = UIAlertController(title: "Unsuccessful Login", message: "Retry please", preferredStyle: .alert)
                            }
                        else {
                             _ = UIAlertController(title: "Unsuccessful Login", message: "Invalid Username and/or Password", preferredStyle: .alert)
                            }
            }
            self.performSegue(withIdentifier: "goToMainScreenSegue", sender: nil)
            
            
        }}
        private func loginCompletion() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let MainScreen: TabBarLocationsViewController = storyboard.instantiateViewController(withIdentifier: "MapTabBar") as! TabBarLocationsViewController
        UIApplication.shared.keyWindow?.rootViewController?.present(MainScreen, animated: true)
        
    }
    //Keyboard Methods
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        view.frame.origin.y = -(getKeyboardHeight(notification))
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }
} */
        
