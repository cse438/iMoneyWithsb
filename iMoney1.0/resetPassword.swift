//
//  resetPassword.swift
//  iMoney1.0
//
//  Created by 文静 on 01/12/2016.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase
class resetPassword: UIViewController{
    @IBOutlet weak var emailText: UITextField!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    @IBAction func resetPassword(_ sender: Any) {
        FIRAuth.auth()!.sendPasswordReset(withEmail: emailText.text!, completion: { (error) in
            if error == nil{
                print("An email with information on how to reset your password has been sent to you.")
                let passwordAlert = UIAlertController(title: "Successful",
                                                      message: "An email with information on how to reset your password has been sent to you.",
                                                      preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK",
                                                  style: .default)
                passwordAlert.addAction(dismissAction)
                self.present(passwordAlert, animated: true, completion: nil)
            }else{
                let passwordAlert = UIAlertController(title: "Sorry",
                                                    message: "Email address not found, please sign up!",
                                                    preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK",
                                                  style: .default)
                passwordAlert.addAction(dismissAction)
                self.present(passwordAlert, animated: true, completion: nil)
            }
        })
    }

}
