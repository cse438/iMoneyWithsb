//
//  transferController.swift
//  iMoney1.0
//
//  Created by John Han on 11/28/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase

class transferController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var acntPickerView1: UIPickerView!
    
    @IBOutlet weak var acntPickerView2: UIPickerView!
    
    @IBOutlet weak var note: UITextView!
    
    var accounts = [Account]();
    
    var ref: FIRDatabaseReference!
    
    var acnt1 : Account?
    
    var acnt2 : Account?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
        acntPickerView1.dataSource = self;
        acntPickerView1.delegate = self;
        
        acntPickerView2.dataSource = self;
        acntPickerView2.delegate = self;
        
        acntPickerView1.tag = 0
        
        acntPickerView2.tag = 1
        
        fetchAccounts()
        
        let emptyAccnt = Account(id:"", AccountNumber: "", balance : "", owner : "")
        accounts.append(emptyAccnt)
        hideKeyboardWhenTappedAround()
    }
    
    
    func fetchAccounts(){
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.acntPickerView1.reloadAllComponents()
            self.acntPickerView2.reloadAllComponents()
            guard snapshot.exists() else {
                return
            }
            let accntsDict = snapshot.value as? [String : [String : String]] ?? [:]
            for (accntID, accnt) in accntsDict {
                let account = Account(id:accntID, AccountNumber: accnt["accountNumber"]!, balance : accnt["balance"]!, owner : accnt["owner"]!)
                
                self.accounts.append(account)
                self.acntPickerView1.reloadAllComponents()
                self.acntPickerView2.reloadAllComponents()
            }
        }) // End of observeSingleEvent
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        if pickerView.tag == 0  {
            return accounts[row].AccountNumber
        }
        return accounts[row].AccountNumber
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return accounts.count
        }
        return accounts.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == acntPickerView1{
            acnt1 = accounts[row]
        }else{
            acnt2 = accounts[row]
        }
    }
    
    
    @IBAction func didTapTransfer(_ sender: Any) {
        let id = (FIRAuth.auth()?.currentUser?.uid)!
        
        let amnt = amount.text!
        
        if acnt1 == nil || acnt2 == nil || acnt1!.AccountNumber == "" || acnt2!.AccountNumber == "" || amnt == "" {
            let myAlert = Alert(title: "Sorry", message: "Please don't leave amount empty or leave category and account unselected", target: self)
            myAlert.show()
            return
        }
        if acnt1!.AccountNumber == acnt2!.AccountNumber {
            let myAlert = Alert(title: "Sorry", message: "Please select differnet accounts.", target: self)
            myAlert.show()
            return
        }
        if Double(amnt) == nil || Double(amnt)! <= 0 {
            let myAlert = Alert(title: "Sorry", message: "Please enter only valid number for amount", target: self)
            myAlert.show()
            return
        }
        
        let nt = note.text!
        
        let newAmnt1 = Double((acnt1?.balance)!)! - Double(amnt)!
        
        let newAmnt2 = Double((acnt2?.balance)!)! + Double(amnt)!
        let date = NSDate()
        var formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone.local
        let defaultTimeZoneStr = formatter.string(from: date as Date);
        self.ref.child("Accounts").child(id).child(acnt1!.id).setValue(["owner":acnt1!.owner,"accountNumber":acnt1!.AccountNumber, "balance":String(newAmnt1)])
        self.ref.child("Accounts").child(id).child(acnt2!.id).setValue(["owner":acnt2!.owner,"accountNumber":acnt2!.AccountNumber, "balance":String(newAmnt2)])
        
        self.ref.child("Transfers").child(id).childByAutoId().setValue(["from": acnt1!.AccountNumber, "to": acnt2!.AccountNumber, "amount": String(amnt), "note" : nt, "date": defaultTimeZoneStr])
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
