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

class earningController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    let locationManager = CLLocationManager()
    
    
    var currentLocation = CLLocation()
    
    func determineCurrentLocation()
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        if CLLocationManager.locationServicesEnabled() {
           
            locationManager.startUpdatingLocation()
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
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        mapView.addAnnotation(myAnnotation)
        
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
