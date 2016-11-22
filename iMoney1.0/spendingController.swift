//
//  spendingController.swift
//  iMoney1.0
//
//  Created by John Han on 11/20/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class spendingController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var amount: UITextField!
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var catePicker: UIPickerView!
    
    @IBOutlet weak var accountPicker: UIPickerView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
     let locationManager = CLLocationManager()
    
    
    var currentLocation = CLLocation()
    
    
    var category = ["Clothes", "Food", "Living", "Transport"];
    var accounts = [String]();
    
    var cateStr : String = ""
    var accntStr : String = ""
//    var subcategory0 = ["Pants","Dresses","Overcoat",]
    
    
  
    func determineCurrentLocation()
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.startUpdatingLocation()
        }
            
            
        }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var userLocation = locations[0]
        if CLLocationManager.locationServicesEnabled() {
            userLocation = locations[0]}
        currentLocation = userLocation
        print("The current location is \(userLocation)")
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
    
        
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        mapView.addAnnotation(myAnnotation)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        
       determineCurrentLocation()
        
        
        // Do any additional setup after loading the view.
        catePicker.dataSource = self;
        catePicker.delegate = self;
        
        accountPicker.dataSource = self;
        accountPicker.delegate = self;
        
        catePicker.tag = 0
        accountPicker.tag = 1
        
        fetchAccounts()
        
    }
    
    
    func fetchAccounts(){
        print("strat to query")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            let accntsDict = snapshot.value as? [String : [String : String]] ?? [:]
            for (accntID, accnt) in accntsDict {
                print("in here")
                print("id" + accntID)
                print("accountNumber" + accnt["accountNumber"]!)
                self.accounts.append(accnt["accountNumber"]!)
            }
            print("end of query")
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
        
        if pickerView.tag == 0 {
            return category[row]
        }
        return accounts[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return category.count
        }
        return accounts.count

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView.tag == 0{
            cateStr = category[row]
        }
        accntStr = accounts[row]
    }
    

    @IBAction func addSpending(_ sender: Any) {
        let id = (FIRAuth.auth()?.currentUser?.uid)!
        let amnt = amount.text!
        let nt = note.text!
        let loc: [Double] = [currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]
        
        print(cateStr)
        print(accntStr)
        print(amnt)
        print(nt)
        print(loc)
        
        self.ref.child("Records").child(id).childByAutoId().setValue(["category":cateStr, "accountNumber":accntStr, "amount":amnt, "note": nt])
        
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
