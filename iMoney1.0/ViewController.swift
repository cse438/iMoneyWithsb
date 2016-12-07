//
//  ViewController.swift
//  iMoney1.0
//
//  Created by 文静 on 18/11/2016.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        currentUser = FIRAuth.auth()?.currentUser
        print("currentuser is:  \(currentUser)")
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentUser = FIRAuth.auth()?.currentUser
        guard currentUser == nil else {
            self.performSegue(withIdentifier: "toDashboard", sender: nil)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = self.emailField.text, let password = self.passwordField.text else {
            return
        }
        // Sign user in
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            guard let user = user, error == nil else {
                let signInAlert = UIAlertController(title: "Sorry",
                                                    message: "Email and password combination is not valid, please sign up or try again.",
                                                    preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK",
                                                  style: .default)
                signInAlert.addAction(dismissAction)
                self.present(signInAlert, animated: true, completion: nil)
                return
            }
            
            self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // Check if user already exists
                guard !snapshot.exists() else {
                    print(user.uid)
                    self.performSegue(withIdentifier: "toDashboard", sender: sender)
                    return
                }
            }) // End of observeSingleEvent
        }) // End of signIn
    }
    
    @IBAction func signUpDidTouch(_ sender: Any) {
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
       
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        FIRAuth.auth()!.signIn(withEmail: self.emailField.text!,
                                                                                               password: self.passwordField.text!)
                                                                        self.saveUserInfo(user!, withEmail: emailField.text!)
                                                                        self.performSegue(withIdentifier: "toDashboard", sender: sender)
                                                                    }
                                                                    else {
                                                                        let signUpAlert = UIAlertController(title: "Sorry",
                                                                                                      message: "Can't create account",
                                                                                                      preferredStyle: .alert)
                                                                        let dismissAction = UIAlertAction(title: "OK",
                                                                                                          style: .default)
                                                                        signUpAlert.addAction(dismissAction)
                                                                        self.present(signUpAlert, animated: true, completion: nil)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveUserInfo(_ user: FIRUser, withEmail email: String) {
        
        // Create a change request
        let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
        changeRequest?.displayName = email
        
        // Commit profile changes to server
        changeRequest?.commitChanges() { (error) in
            
            if let error = error {
                return
            }
            // [START basic_write]
            self.ref.child("users").child(user.uid).setValue(["Email": email])
            // [END basic_write]
        }
    }
}

