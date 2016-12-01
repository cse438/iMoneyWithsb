//
//  earningController.swift
//  iMoney1.0
//
//  Created by Arthur on 11/21/16.
//  Copyright © 2016 文静. All rights reserved.
//
import Firebase
import CoreLocation
import MapKit
import UIKit

class earningController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var accountPicker: UIPickerView!
    @IBOutlet weak var amount: UITextField!
    
    @IBOutlet weak var note: UITextView!
       var ref: FIRDatabaseReference!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
   let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    var currentLocation = CLLocation()
    
        var accounts = [Account]();
        var selectedAccnt : Account?
    
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func cameraClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker,animated: true, completion: nil)
        
    }
    var base64String: NSString!

    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "image has been saved to your photos." , preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
            present(ac, animated:true, completion:nil)
        } else{
            let ac = UIAlertController(title:"Save error", message: error?.localizedDescription,preferredStyle: .alert)
            ac.addAction(UIAlertAction(title:"OK", style: .default, handler:nil))
            present(ac, animated:true, completion:nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageDisplay.image = info[UIImagePickerControllerOriginalImage] as? UIImage;dismiss(animated: true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(imageDisplay.image!,self,#selector(spendingController.image(_:didFinishSavingWithError:contextInfo:)),nil)
    }
    
    
    func determineCurrentLocation()
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        if CLLocationManager.locationServicesEnabled() {
           
            locationManager.startUpdatingLocation()
            self.myAnnotation.title = "Current location"
            mapView.addAnnotation(myAnnotation)
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var userLocation = CLLocation()
        if CLLocationManager.locationServicesEnabled() {
            userLocation = locations[0]}
        currentLocation = userLocation
        
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
       
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        determineCurrentLocation()
        // Do any additional setup after loading the view.
        accountPicker.dataSource = self;
        accountPicker.delegate = self;
        fetchAccounts()
        print("View Loading1")
        let emptyAccnt = Account(id:"", AccountNumber: "", balance : "", owner : "")
        accounts.append(emptyAccnt)

    }
    override func viewWillAppear(_ animated: Bool) {
        print("View appearing1")
    }
    
    func fetchAccounts(){
        print("earn start to query")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.accountPicker.reloadAllComponents()
            guard snapshot.exists() else {
                return
            }
            let accntsDict = snapshot.value as? [String : [String : String]] ?? [:]
            for (accntID, accnt) in accntsDict {
                
                print("id" + accntID)
                print("accountNumberearn" + accnt["accountNumber"]!)
                let account = Account(id:accntID, AccountNumber: accnt["accountNumber"]!, balance : accnt["balance"]!, owner : accnt["owner"]!)
                self.accounts.append(account)
                self.accountPicker.reloadAllComponents()
            }
            print("earn end of query")
        }) // End of observeSingleEvent
    }
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
                return accounts[row].AccountNumber
        
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return accounts.count
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print("earnrow:  \(row)")
        
         selectedAccnt = accounts[row]
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveTouched(_ sender: Any) {
        let id = (FIRAuth.auth()?.currentUser?.uid)!
        let amnt = amount.text!
        let nt = note.text!
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        let date = NSDate()
        var formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone.local
        let defaultTimeZoneStr = formatter.string(from: date as Date);
        
        var data = NSData()
        data = UIImageJPEGRepresentation(imageDisplay!.image!, 0.8)! as NSData
        
        let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        if selectedAccnt == nil || amnt == "" {
            print("error")
            return
        }
        print("-----------------------------")
        print("account number is " + selectedAccnt!.AccountNumber)
        
        print(amnt)
        print(nt)
        print(base64String)
        
        self.ref.child("Earn").child(id).child(selectedAccnt!.id).childByAutoId().setValue([ "accountNumber":selectedAccnt!.AccountNumber, "amount":amnt, "note": nt, "date": defaultTimeZoneStr, "locationLatitude": latitude , "locationLongitude": longitude, "image" : base64String])
        
        let blc = Int(selectedAccnt!.balance)
        let earn = Int(amnt)
        let newBlc = blc! + earn!
        
        print(newBlc)
        
    self.ref.child("Accounts").child(id).child(selectedAccnt!.id).setValue(["owner":selectedAccnt!.owner,"accountNumber":selectedAccnt!.AccountNumber, "balance":String(newBlc)])
        
    }
//    @IBAction func cancelTouched(_ sender: Any) {
//        
//        print("you were messing with me???")
//    }
    
}
