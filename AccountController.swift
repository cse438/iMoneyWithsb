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

class AccountController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var balanceButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var spendingButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var accounts: [Account] = []
    var numberToID: [String : String] = [:]
    var accountImage: UIImage! = UIImage(named: "Money.png")
    var accountRecords: [String : [Record]] = [:]
    var spendings: [Record] = []
    var earnings: [Record] = []
    var inUseRecords: [Record] = []
    var formatter: DateFormatter! = nil
    
    let locationManager = CLLocationManager()
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        self.title = "iMoney"
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
        }
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let month = calendar.component(.month, from: date)
        let months = calendar.shortMonthSymbols
        let monthSymbol = months[month-1]
        let year = calendar.component(.year, from: date)
        
        self.dataLabel.text = "\(monthSymbol) \(day), \(year)"
        
        theCollectionView.dataSource = self
        theCollectionView.delegate = self
        
        let editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editPressed))
        self.navigationItem.setRightBarButton(editButton, animated: true)
    }
    func editPressed(){
        print("edit pressed!")

        if(self.navigationItem.rightBarButtonItem?.title == "Edit"){
            
            let myAlert = Alert(title: "Warning", message: "Once account is deleted, all records related to this account will also be deleted and cannot be restored!", target: self)
            myAlert.show()
            self.navigationItem.rightBarButtonItem?.title = "Done"
            
            //Looping through CollectionView Cells in Swift
            
            for item in self.theCollectionView!.visibleCells as! [AccountCell] {
                
                let indexpath : IndexPath = self.theCollectionView!.indexPath(for: item as AccountCell)!
                let cell : AccountCell = self.theCollectionView!.cellForItem(at: indexpath) as! AccountCell
                
                let close : UIButton = cell.viewWithTag(102) as! UIButton
                close.isHidden = false
            }
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Edit"
            self.theCollectionView?.reloadData()
        }

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
                                        
                                        let numberString = accountNumber.text ?? ""
                                        let balanceString = balance.text ?? ""
                                        if numberString == "" || balanceString == "" {
                                            let myAlert = Alert(title: "Sorry", message: "Please don't leave account number or balance empty.", target: self)
                                            myAlert.show()
                                            return
                                        }
                                        if Double(balanceString) == nil {
                                            let myAlert = Alert(title: "Sorry", message: "Please enter valid number for balance.", target: self)
                                            myAlert.show()
                                            return
                                        }
                                        if self.numberToID[numberString] != nil {
                                            let myAlert = Alert(title: "Sorry", message: "Account Number Already Exists!", target: self)
                                            myAlert.show()
                                            return
                                        }
                                        
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
        print("currentUser is: \(uid)")
        self.ref.child("Accounts").child(uid).observe(.value, with: { (snapshot) in
            var totalBlc = 0.0
            self.accounts = []
            let accountsDict = snapshot.value as? [String : [String : String]] ?? [:]
            self.numberToID = [:]
            for (accountID, account) in accountsDict {
                print(accountID + ": " + account["balance"]!)
                let blcOp = Double(account["balance"] ?? "")
                let blc = blcOp != nil ? blcOp! : 0
                let id = accountID
                let acountNumber = account["accountNumber"] ?? ""
                let owner = account["owner"] ?? ""
                let accountOb = Account(id: id, AccountNumber: acountNumber, balance: String(blc), owner: owner)
                self.accounts.append(accountOb)
                totalBlc += blc
                let number = accountOb.AccountNumber
                if number != "" {
                    self.numberToID.updateValue(accountOb.id, forKey: number)
                }
                print("userRecords cleared")
            }
            self.balanceButton.setTitle("\(round(totalBlc*100)/100)", for: UIControlState.normal)
            print("end of query")
            print("We get \(self.accounts.count) accounts")
            print("before reloading data")
            self.theCollectionView.reloadData()
            print("after reloading data")
            print("we have \(self.accounts.count) accounts")
            
            self.fetchSpedingData()
            self.fetchEarningData()
        }) // End of observeSingleEvent
    }
    
    func fetchSpedingData() {
        print("start fetching spending")
        let userRecordsRef = self.ref.child("Records").child(self.currentUser.uid)
        userRecordsRef.observe(.value, with: { snapshot in
            self.spendings = []
            var total = 0.0
            let accountDict = snapshot.value as? NSDictionary ?? [:]
            for (accountID, accountValue) in accountDict{
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
                }
            }
            self.spendingButton.setTitle("\(round(total*100)/100)", for: UIControlState.normal)
        })
        return
    }
    
    func fetchEarningData() {
        print("start fetching earning")
        let userRecordsRef = self.ref.child("Earn").child(self.currentUser.uid)
        print("earnings cleared")
        userRecordsRef.observe(.value, with: { snapshot in
            var total = 0.0
            self.earnings = []
            let accountDict = snapshot.value as? NSDictionary ?? [:]
            for (accountID, accountValue) in accountDict{
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
                }
            }
            self.incomeButton.setTitle("\(round(total*100)/100)", for: UIControlState.normal)
        })
        return
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashboardToHistory" {
            if let toCV = segue.destination as? HistoryController {
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
            let i = indexPath.row
            let account = self.accounts[i]
            
            cell.nameLabel.text = account.AccountNumber
            cell.balanceLabel.text = "balance: " + account.balance
            print("cell " + account.AccountNumber + " populated.")
            if self.navigationItem.rightBarButtonItem!.title == "Edit" {
                cell.closeImage?.isHidden = true
            } else {
                cell.closeImage?.isHidden = false
            }
          
            cell.closeImage?.layer.setValue(indexPath.row, forKey: "index")
            
            
            cell.closeImage?.addTarget(self, action: #selector(AccountController.deletePhoto(_:)), for: UIControlEvents.touchUpInside)
        }
        return cell
    }
    func deletePhoto(_ sender:UIButton) {
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        let accountID = accounts[i].id
        self.ref.child("Accounts").child(self.currentUser.uid).child(accountID).removeValue()
        self.ref.child("Records").child(self.currentUser.uid).child(accountID).removeValue()
        self.ref.child("Earn").child(self.currentUser.uid).child(accountID).removeValue()
        
        accounts.remove(at: i)
        self.theCollectionView!.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let i = indexPath.row
        print("\(i) cell selected")
        let id = accounts[i].id
        let accountNumber = accounts[i].AccountNumber
        var records: [Record] = []
        for spending in self.spendings {
            if spending.account == accountNumber {
                records.append(spending)
            }
        }
        for earning in self.earnings {
            if earning.account == accountNumber {
                records.append(earning)
            }
        }
        self.accountRecords[id] = records
        self.inUseRecords = self.accountRecords[id]!
        self.performSegue(withIdentifier: "dashboardToHistory", sender: nil)
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
