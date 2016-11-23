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

class earningController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
   let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    var currentLocation = CLLocation()
    
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBAction func cameraClicked(_ sender: Any) {
        
        
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker,animated: true, completion: nil)
        
    }
    
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
        
        
        print("The current location is \(userLocation)")
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        
        mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
       
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        determineCurrentLocation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveTouched(_ sender: Any) {
        
        let loc: [Double] = [currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]
        print(loc)
    }
    @IBAction func cancelTouched(_ sender: Any) {
        
        print("you were messing with me???")
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
