//
//  AccountController.swift
//  iMoney1.0
//
//  Created by John Han on 11/20/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AccountController: UIViewController, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var accountsDict: [String : [String : String]] = [:]
    var accountImage: UIImage! = UIImage(named: "Money.png")
    
    let locationManager = CLLocationManager()
    override func viewWillAppear(_ animated: Bool) {
            }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        
        ref = FIRDatabase.database().reference()
        // Do any additional setup after loading the view.
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            let email = user.email!
            let uid = user.uid
            self.currentUser = User(uid:uid,email:email)
            
            

        }
        
        print("strat to query")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            self.accountsDict = snapshot.value as? [String : [String : String]] ?? [:]
            for (accountID, account) in self.accountsDict {
                print(accountID + ": " + account["balance"]!)
            }
            print("end of query")
            print("We get \(self.accountsDict.count) accounts")
            
            print("before reloading data")
            self.theCollectionView.reloadData()
            print("after reloading data")
            print("we have \(self.accountsDict.count) accounts")
        }) // End of observeSingleEvent

        
        theCollectionView.dataSource = self
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of cell: \(accountsDict.count) returned.")
        return accountsDict.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountCell", for: indexPath) as! AccountCell
        let accountsArray = Array(accountsDict.values)
        if accountsDict.count != 0 {
            let account = accountsArray[indexPath.row]
            
            cell.theImage.image = accountImage!
            cell.nameLabel.text = account["accountNumber"]
            cell.balanceLabel.text = "balance: " + account["balance"]!
            print("cell " + (account["accountNumber"])! + " populated.")
        }
        return cell
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
