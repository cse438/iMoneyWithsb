//
//  statisticsController.swift
//  iMoney1.0
//
//  Created by Arthur on 11/21/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import MapKit

class statisticsController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var coordinatesSet:[CLLocationCoordinate2D]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        coordinatesSet?.append(CLLocationCoordinate2DMake(0.0, 0.0))
        coordinatesSet?.append(CLLocationCoordinate2DMake(33.0, 25.0))
        coordinatesSet?.append(CLLocationCoordinate2DMake(35.0, 45.0))
        coordinatesSet?.append(CLLocationCoordinate2DMake(57.0, 67.0))
        coordinatesSet?.append(CLLocationCoordinate2DMake(57.0, 64.0))
        fetchCoordinates()
    
        for coordinate in coordinatesSet!{
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        myAnnotation.title = (String(coordinate.latitude) + "," + String(coordinate.longitude))
            
            mapView.addAnnotation(myAnnotation)} 

    }
    func fetchCoordinates(){
        
        
        
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
