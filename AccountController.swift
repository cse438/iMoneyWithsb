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
    
    @IBOutlet weak var datetime: UITextField!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var balanceButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var spendingButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var accountsDict: [String : [String : String]] = [:]
    var accounts: [Account] = []
    var accountImage: UIImage! = UIImage(named: "Money.png")
    var spendings: [Record] = []
    var earnings: [Record] = []
    var inUseRecords: [Record] = []
    var formatter: DateFormatter! = nil
    
    let locationManager = CLLocationManager()
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        
        ref = FIRDatabase.database().reference()
        
        self.formatter = DateFormatter();
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        self.formatter.timeZone = NSTimeZone.local
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            let email = user.email!
            let uid = user.uid
            self.currentUser = User(uid:uid,email:email)
            
            self.fetchAccounts()
            self.fetchSpedingData()
            self.fetchEarningData()
        }
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        self.datetime.text = "\(month)-\(day), \(year)"
        
        theCollectionView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func balanceTapped(_ sender: Any) {
        self.inUseRecords = self.earnings + self.spendings
        self.performSegue(withIdentifier: "dashboardToHistory", sender: nil)
    }
    
    @IBAction func incomeTapped(_ sender: Any) {
        self.inUseRecords = self.earnings
        self.performSegue(withIdentifier: "dashboardToHistory", sender: nil)
    }
    
    @IBAction func spendingTapped(_ sender: Any) {
        self.inUseRecords = self.spendings
        self.performSegue(withIdentifier: "dashboardToHistory", sender: nil)
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
    
    func fetchAccounts () {
        print("strat to query")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observe(.value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            self.accountsDict = snapshot.value as? [String : [String : String]] ?? [:]
            var totalBlc = 0.0
            for (accountID, account) in self.accountsDict {
                print(accountID + ": " + account["balance"]!)
                let blcOp = Double(account["balance"] ?? "")
                let blc = blcOp != nil ? blcOp! : 0
                let id = account["id"] ?? ""
                let acountNumber = account["accountNumber"] ?? ""
                let owner = account["owner"] ?? ""
                let accountOb = Account(id: id, AccountNumber: acountNumber, balance: String(blc), owner: owner)
                self.accounts.append(accountOb)
                totalBlc += blc
            }
            self.balanceButton.setTitle("\(round(totalBlc*100)/100)", for: UIControlState.normal)
            print("end of query")
            print("We get \(self.accounts.count) accounts")
            print("before reloading data")
            self.theCollectionView.reloadData()
            print("after reloading data")
            print("we have \(self.accounts.count) accounts")
        }) // End of observeSingleEvent
    }
    
    func fetchSpedingData() {
        let userRecordsRef = self.ref.child("Records").child(self.currentUser.uid)
        self.spendings = []
        var total = 0.0
        userRecordsRef.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                return
            }
            let accountDict = snapshot.value as? NSDictionary ?? [:]
            for (_, accountValue) in accountDict{
                let recordDict = accountValue as? [String : [String : Any]] ?? [:]
                for (recordID, record) in recordDict {
                    let id = recordID
                    let account = record["accountNumber"] as? String ?? ""
                    let amountString = record["amount"] as? String ?? ""
                    let amount = Double(amountString) ?? 0
                    let category = record["category"] as? String ?? ""
                    let dateString = record["date"] as? String ?? ""
                    let date = self.formatter.date(from: dateString) ?? Date(timeIntervalSince1970: 0)
                    let imageURL = record["imageURL"] as? String ?? ""
                    let lat = record["locationLatitude"] as? CLLocationDegrees ?? 0
                    let long = record["locationLongitude"] as? CLLocationDegrees ?? 0
                    let note = record["note"] as? String ?? ""
                    self.spendings.append(Record(id: id, account: account, amount: amount, category: category, date: date, long: long, lat: lat, imageURL: imageURL, note: note))
                    
                    total += amount
                    print("Spending is: \(self.spendings[self.spendings.count - 1])")
                }
            }
            self.spendingButton.setTitle("\(round(total*100)/100)", for: UIControlState.normal)
        })
        return
    }
    
    func fetchEarningData() {
        let userRecordsRef = self.ref.child("Earn").child(self.currentUser.uid)
        self.earnings = []
        var total = 0.0
        userRecordsRef.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                return
            }
            let accountDict = snapshot.value as? NSDictionary ?? [:]
            for (_, accountValue) in accountDict{
                let recordDict = accountValue as? [String : [String : Any]] ?? [:]
                for (recordID, record) in recordDict {
                    let id = recordID
                    let account = record["accountNumber"] as? String ?? ""
                    let amountString = record["amount"] as? String ?? ""
                    let amount = Double(amountString) ?? 0
                    let category = ""
                    let dateString = record["date"] as? String ?? ""
                    let date = self.formatter.date(from: dateString) ?? Date(timeIntervalSince1970: 0)
                    let imageURL = record["imageURL"] as? String ?? ""
                    let lat = record["locationLatitude"] as? CLLocationDegrees ?? 0
                    let long = record["locationLongitude"] as? CLLocationDegrees ?? 0
                    let note = record["note"] as? String ?? ""
                    self.earnings.append(Record(id: id, account: account, amount: amount, category: category, date: date, long: long, lat: lat, imageURL: imageURL, note: note))
                    
                    total += amount
                    print("Earning is: \(self.earnings[self.earnings.count - 1])")
                }
            }
            self.incomeButton.setTitle("\(round(total*100)/100)", for: UIControlState.normal)
        })
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardToHistory" {
            if let toCV = segue.destination as? HistoryController {
//                toCV.spendings = self.spendings
//                toCV.earnings = self.earnings
                toCV.inUseRecords = self.inUseRecords
                toCV.accounts = self.accounts
                print("data passed")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of cell: \(accounts.count) returned.")
        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "accountCell", for: indexPath) as! AccountCell
        if self.accounts.count != 0 {
            let account = self.accounts[indexPath.row]
            
            cell.theImage.image = accountImage!
            cell.nameLabel.text = account.AccountNumber
            cell.balanceLabel.text = "balance: " + account.balance
            print("cell " + account.AccountNumber + " populated.")
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
