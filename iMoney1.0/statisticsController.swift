//
//  statisticsController.swift
//  iMoney1.0
//
//  Created by Arthur on 11/21/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class statisticsController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var longitudeSet: [CLLocationDegrees] = []
    var latitudeSet: [CLLocationDegrees] = []
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var coordinateSet: [CLLocationCoordinate2D]? = []
    var records: [String: [String: Any]]? = [:]
    var titles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
       
        
        
        ref = FIRDatabase.database().reference()
        FIRAuth.auth()!.addStateDidChangeListener{auth, user in
        guard let user = user else { return }
        let email = user.email!
        let uid = user.uid
            self.currentUser = User(uid:uid,email:email)
        }
        
      
        let uid = (FIRAuth.auth()?.currentUser?.uid)!
        self.ref.child("Records").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard snapshot.exists() else {
                return
            }
            
            
            //let records = snapshot.value as? [String: [String : Any]] ?? [:]
            let records = snapshot.value as? [String: [String : [String : Any]]] ?? [:]
          
             print("*********************")
             print(records)
             print("*********************")
            
            if records.count != 0 {
                print("--------------------------------------")
                
                for singleRecord in records.values{
//                    self.longitudeSet.append(singleRecord["locationLongitude"] as! CLLocationDegrees)
//                    self.latitudeSet.append(singleRecord["locationLatitude"] as! CLLocationDegrees)
//                    self.titles.append(String(describing: singleRecord["Amount"]) + "for" + String(describing: singleRecord["Category"]))
                    for oneRecord in singleRecord.values{
                        
                       self.latitudeSet.append(oneRecord["locationLatitude"] as! CLLocationDegrees)
                       self.longitudeSet.append(oneRecord["locationLongitude"] as! CLLocationDegrees)
                       var str1: String = oneRecord["amount"] as! String
                       var str2: String = oneRecord["category"] as! String
                       self.titles.append(str1 + "$ for " + str2)
                      }
                }
                
                
                var i: Int = 0
                while(i < self.longitudeSet.count){
                    self.coordinateSet?.append(CLLocationCoordinate2D())
                    self.coordinateSet?[i].latitude = self.latitudeSet[i]
                    self.coordinateSet?[i].longitude = self.longitudeSet[i]
                    print("@@@@@@@@@@@@@@@@@@")
                    print(self.coordinateSet?[i])
                    print("@@@@@@@@@@@@@@@@@@")
                    i = i + 1
                    
                }
                
                var j: Int = 0
                for coordinate in self.coordinateSet!{
                    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
                    myAnnotation.coordinate = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
                    myAnnotation.title = (self.titles[j])
                    j += 1
                    self.mapView.addAnnotation(myAnnotation)
                }
            
                
            }
            
            
        })
        
        
        
       
       
        
        
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
