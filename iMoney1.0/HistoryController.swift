//
//  HistoryController.swift
//  iMoney1.0
//
//  Created by 吕Mike on 12/1/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var theTable: UITableView!
//    @IBOutlet weak var allButton: UIButton!
//    @IBOutlet weak var incomeButton: UIButton!
//    @IBOutlet weak var spendingButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser!
    var accountsDict: [String : [String : String]] = [:]
    var numberToID: [String : String] = [:]
//    var spendings: [Record] = []
//    var earnings: [Record] = []
//    var allReords: [Record] = []
    var indexSelected: Int = 0
    var inUseRecords: [Record] = []
    var formatter: DateFormatter! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        currentUser = FIRAuth.auth()?.currentUser
        self.formatter = DateFormatter();
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        self.formatter.timeZone = NSTimeZone.local
        
        for (accountID, account) in accountsDict {
            let number = account["accountNumber"] ?? ""
            if number != "" {
                self.numberToID.updateValue(accountID, forKey: number)
            }
        }
//        allReords = spendings + earnings
//        spendings.sort(by: { $0.date > $1.date })
//        earnings.sort(by: { $0.date > $1.date })
//        allReords.sort(by: { $0.date > $1.date })
        inUseRecords.sort(by: { $0.date > $1.date})
        theTable.dataSource = self
        theTable.delegate = self
        theTable.tableHeaderView = nil
        theTable.reloadData()
        print("data received, is : ")
        print(self.inUseRecords)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistoryToDetail" {
            // prepare here, records is stored in self.inUseRecords[self.indexSelected]
            print("preparing for detail")
            return
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inUseRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        let amount = self.inUseRecords[i].amount
        let category = self.inUseRecords[i].category
        let prefix = category != "" ? category : "Income"
        let date = self.formatter.string(from: self.inUseRecords[i].date)
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(prefix): $\(amount), at \(date)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle deleting, remove from remote database, remove record from array
            let i = indexPath.row
            let recordID = self.inUseRecords[i].id
            let accountNumber = self.inUseRecords[i].account
            let accountID = self.numberToID[accountNumber]!
            let tableName = self.inUseRecords[i].category == "" ? "Earn" : "Records"
            self.ref.child(tableName).child(self.currentUser.uid).child(accountID).child(recordID).removeValue()
            // maintainance on account balance needed?
            self.inUseRecords.remove(at: i)
            theTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let i = indexPath.row
        self.indexSelected = i
        print("row \(i) selected")
        self.performSegue(withIdentifier: "HistoryToDetail", sender: nil)
        print("after performing")
    }

    
}
