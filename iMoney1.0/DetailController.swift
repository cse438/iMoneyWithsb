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
import MapKit

class DetailController: UIViewController{
    
    @IBOutlet weak var imageDisplay: UIImageView!
    var recordDetail: Record = Record(id: "", account: "", amount: 0.0, category: "", date: Date(timeIntervalSince1970: 1000000), long: 0.0, lat: 0.0, imageURL: "", note: "")
    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var account: UILabel!
   
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var showImage: UIButton!
    
    @IBAction func showImageClicked(_ sender: Any) {
        let url : NSURL = NSURL(string: recordDetail.imageURL)!
        if UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    
   
    init() {
        super.init(nibName:nil, bundle:nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
               self.imageDisplay.image = UIImage(data: data)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        print("------------------------------------")
        print(recordDetail.imageURL)
        print("------------------------------------")

        if recordDetail.category == "" {
            category.text = "/"
        }
        else { category.text = recordDetail.category
        }
        account.text = recordDetail.account
        amount.text = String(recordDetail.amount) + "$"
        note.text = recordDetail.note
        myAnnotation.title = ""
        self.myAnnotation.coordinate = CLLocationCoordinate2DMake(recordDetail.lat, recordDetail.long)
        mapView.addAnnotation(myAnnotation)
        if recordDetail.imageURL != "" {
            if let checkedUrl = NSURL(string: recordDetail.imageURL){
                imageDisplay.contentMode = .redraw
                imageDisplay.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
                downloadImage(url: checkedUrl as URL)
            }
        }
        let date = recordDetail.date
        var formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        formatter.timeZone = NSTimeZone.local
        let defaultTimeZoneStr = formatter.string(from: date as Date);
        dateLabel.text = defaultTimeZoneStr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
