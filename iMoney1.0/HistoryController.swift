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
    @IBOutlet weak var theMinDatePicker: UIDatePicker!
    @IBOutlet weak var theMaxDatePicker: UIDatePicker!
    
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser!
    var accounts: [Account] = []
    var numberToID: [String : String] = [:]
    var indexSelected: Int = 0
    var inUseRecords: [Record] = []
    var recordsInDate: [Record] = []
//    var indexToIndex: [Int] = []
    var formatter: DateFormatter! = nil
    var calendar: Calendar! = nil
    var minDate: Date = Date()
    var maxDate: Date = Date()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        currentUser = FIRAuth.auth()?.currentUser
        self.formatter = DateFormatter();
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        self.formatter.timeZone = NSTimeZone.local
        self.calendar = Calendar.current
        self.calendar.timeZone = NSTimeZone.local
        
        for account in accounts {
            let number = account.AccountNumber
            if number != "" {
                self.numberToID.updateValue(account.id, forKey: number)
            }
        }
        
        inUseRecords.sort(by: { $0.date > $1.date})
        theTable.dataSource = self
        theTable.delegate = self
        theTable.tableHeaderView = nil
        theTable.reloadData()
        
        theMinDatePicker.date = Date()
        theMaxDatePicker.date = Date()
        theMinDatePicker.datePickerMode = .date
        theMaxDatePicker.datePickerMode = .date
        theMinDatePicker.minimumDate = Date(timeIntervalSince1970: 0)
        theMinDatePicker.maximumDate = theMaxDatePicker.date
        theMaxDatePicker.minimumDate = theMinDatePicker.date
        theMaxDatePicker.maximumDate = Date()
        
        let startOfToday = calendar.startOfDay(for: Date())
        let lastMinOfToday = calendar.date(byAdding: .minute, value: 1439, to: Date())!
        let endOfToday = calendar.date(byAdding: .second, value: 59, to: lastMinOfToday)!
        self.minDate = startOfToday
        self.maxDate = endOfToday
        recordsInDate = arrayBetweenIndex(array: self.inUseRecords, minDate: self.minDate, maxDate: self.maxDate)
        
        print("segue performed")
    }
    
    @IBAction func minPickerChanged(_ sender: Any) {
        theMaxDatePicker.minimumDate = theMinDatePicker.date
        minDate = theMinDatePicker.date
        recordsInDate = arrayBetweenIndex(array: self.inUseRecords, minDate: self.minDate, maxDate: self.maxDate)
        self.theTable.reloadData()
    }
    
    @IBAction func maxPickerChanged(_ sender: Any) {
        theMinDatePicker.maximumDate = theMaxDatePicker.date
        let startOfDay = theMaxDatePicker.date
        var dateAtEnd = calendar.date(byAdding: .minute, value: 1439, to: startOfDay)
        dateAtEnd = calendar.date(byAdding: .second, value: 59, to: dateAtEnd!)
        maxDate = dateAtEnd!
        recordsInDate = arrayBetweenIndex(array: self.inUseRecords, minDate: self.minDate, maxDate: self.maxDate)
        print("maxdate is: "+self.formatter.string(from: maxDate))
        self.theTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistoryToDetail" {
            let recordDetail = self.inUseRecords[self.indexSelected]
            let controller = segue.destination as! DetailController
            controller.recordDetail = recordDetail
        }
    }
    
    func arrayBetweenIndex (array: [Record], minDate: Date, maxDate: Date) -> [Record] {
        var ans: [Record] = []
        for record in array {
            if record.date >= minDate && record.date <= maxDate {
                ans.append(record)
            }
        }
        return ans
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordsInDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        let amount = self.recordsInDate[i].amount
        let category = self.recordsInDate[i].category
        let prefix = category != "" ? category : "Income"
        let date = self.formatter.string(from: self.recordsInDate[i].date)
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(prefix): $\(amount), at \(date)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle deleting, remove from remote database, remove record from array
            let i = indexPath.row
            let recordID = self.recordsInDate[i].id
            let accountNumber = self.recordsInDate[i].account
            let accountID = self.numberToID[accountNumber]!
            let tableName = self.recordsInDate[i].category == "" ? "Earn" : "Records"
            self.ref.child(tableName).child(self.currentUser.uid).child(accountID).child(recordID).removeValue()
            print("\(recordID) deleted")
            let index = self.inUseRecords.index(where: { $0.id == recordID })
            if index != nil {
                self.inUseRecords.remove(at: index!)
            }
            self.recordsInDate.remove(at: i)
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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
