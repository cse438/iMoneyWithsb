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

class spendingController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var amount: UITextField!
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var catePicker: UIPickerView!
    
    @IBOutlet weak var accountPicker: UIPickerView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var imageDisplay: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
        var imageUrl: String = ""

     let locationManager = CLLocationManager()
    
    var currentLocation = CLLocation()
    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    
    var category = ["", "Clothes", "Food", "Living", "Transport"];
    var accounts = [Account]();
    
    var cateStr : String = ""
    var selectedAccnt : Account?
//    var subcategory0 = ["Pants","Dresses","Overcoat",]
    
    

    @IBAction func cameraClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker,animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageDisplay?.image = info[UIImagePickerControllerOriginalImage] as? UIImage;dismiss(animated: true, completion: nil)
        imageDisplay?.isUserInteractionEnabled = true
        UIImageWriteToSavedPhotosAlbum((imageDisplay?.image!)!,self,#selector(spendingController.image(_:didFinishSavingWithError:contextInfo:)),nil)
  
    }
 
    
    
    var base64String: NSString!
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        print("in here")
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

    
    
    
    

    
    func determineCurrentLocation()
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.startUpdatingLocation()
            
           
            myAnnotation.title = "Current location"
            mapView.addAnnotation(myAnnotation)
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

      self.myAnnotation.coordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
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
        
        print("View Loading")

        self.accountPicker.selectRow(0, inComponent: 0, animated: true)
        
        let emptyAccnt = Account(id:"", AccountNumber: "", balance : "", owner : "")
        accounts.append(emptyAccnt)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("View appearing")
    }
    
    
    func fetchAccounts(){
        print("strat to query")
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Accounts").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            self.accountPicker.reloadAllComponents()
            guard snapshot.exists() else {
                return
            }
            let accntsDict = snapshot.value as? [String : [String : String]] ?? [:]
            for (accntID, accnt) in accntsDict {
                print("in here")
                print("id" + accntID)
                print("accountNumber" + accnt["accountNumber"]!)
                let account = Account(id:accntID, AccountNumber: accnt["accountNumber"]!, balance : accnt["balance"]!, owner : accnt["owner"]!)
                self.accounts.append(account)
            self.accountPicker.reloadAllComponents()
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
        return accounts[row].AccountNumber
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return category.count
        }
        return accounts.count

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        print("row:  \(row)")
        if pickerView.tag == 0{
            cateStr = category[row]
        }else{
            selectedAccnt = accounts[row]
        }
    }
    

    @IBAction func addSpending(_ sender: Any) {
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

//        var data = NSData()
//        data = UIImageJPEGRepresentation(imageDisplay!.image!, 0.8)! as NSData
//        
//        let base64String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        let storageRef = FIRStorage.storage().reference().child("\(id).png")
        
                if let uploadData = UIImagePNGRepresentation(imageDisplay.image!){
                        storageRef.put(uploadData, metadata: nil, completion: {
                                (metadata, error) in
                
                
                                if error != nil{
                                    print(error)
                                    return
                                }
                                self.imageUrl = (metadata?.downloadURL()?.absoluteString)!
                                print(metadata)
                            })
            
                    }
        if selectedAccnt == nil || cateStr == "" || amnt == "" {
            print("error")
            return
        }

        print("-----------------------------")
        print(cateStr)
        print("account number is " + selectedAccnt!.AccountNumber)
        
        print(amnt)
        print(nt)
        //print(base64String)
        print("-----------------------------")

        
//        self.ref.child("Records").child(id).childByAutoId().setValue(["category":cateStr, "accountNumber":accntStr, "amount":amnt, "note": nt, "locationLatitude": latitude , "locationLongitude": longitude, "image" : base64String])
        self.ref.child("Records").child(id).child(selectedAccnt!.id).childByAutoId().setValue(["category":cateStr, "accountNumber":selectedAccnt!.AccountNumber, "amount":amnt, "note": nt, "date": defaultTimeZoneStr,"locationLatitude": latitude , "locationLongitude": longitude, "imageURL" : imageUrl])
        
            let blc = Int(selectedAccnt!.balance)
            let spd = Int(amnt)
            let newBlc = blc! - spd!
        
            print(newBlc)
        
            self.ref.child("Accounts").child(id).child(selectedAccnt!.id).setValue(["owner":selectedAccnt!.owner,"accountNumber":selectedAccnt!.AccountNumber, "balance":String(newBlc)])
        
        
        
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
