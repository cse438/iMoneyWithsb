//
//  AccountController.swift
//  iMoney1.0
//
//  Created by John Han on 11/20/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase

class AccountController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            let email = user.email!
            let uid = user.uid
            self.currentUser = User(uid:uid,email:email)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addAccount(_ sender: Any) {
        let alert = UIAlertController(title: "Add An Account",
                                      message: "Account",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let accountNumber = alert.textFields![0]
                                        let balance = alert.textFields![1]
                                        
 
                                        let email = self.currentUser!.email
                                        let id = self.currentUser!.uid

                                        print("here is " + email)
                                        print("here is " + id)
                                        self.ref.child("Accounts").child(id).childByAutoId().setValue(["owner":email, "accountNumber":accountNumber.text!, "balance":balance.text!])
                                        
                        
                                        
        }
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { accountNumber in
            accountNumber.placeholder = "Enter your account number"
        }
        
        alert.addTextField { balance in
            balance.placeholder = "Enter the balance"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
