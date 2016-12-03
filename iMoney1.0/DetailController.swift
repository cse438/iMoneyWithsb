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

class DetailController: UIViewController {
    
    var recordDetail: Record = Record(id: "", account: "", amount: 0.0, category: "", date: Date(timeIntervalSince1970: 1000000), long: 0.0, lat: 0.0, imageURL: "", note: "")
    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var imageDisplay: UIImageView!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
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
                imageDisplay.contentMode = .scaleAspectFit
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
