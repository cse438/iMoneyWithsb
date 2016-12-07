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
// for chart
import Charts

class statisticsController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var longitudeSet: [CLLocationDegrees] = []
    var latitudeSet: [CLLocationDegrees] = []
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var coordinateSet: [CLLocationCoordinate2D]? = []
    var records: [String: [String: Any]]? = [:]
    var titles: [String] = []
    // for chart
    @IBOutlet weak var thePieChart: PieChartView!
    var minDate: Date = Date(timeIntervalSince1970: 0)
    var maxDate: Date = Date()
    var recordsForChart: [Record] = []
    var cateArray: [String] = []
    var curCate: Set<String> = Set<String>()
    var uid: String = ""
    
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
        
        // for chart
        self.minDate = Date(timeIntervalSince1970: 0)
        self.maxDate = Date()
        self.uid = uid
        initCates()
        fetchCate()
        fetchData()
        
        self.ref.child("Records").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let records = snapshot.value as? [String: [String : [String : Any]]] ?? [:]
            
            if records.count != 0 {
                for singleRecord in records.values{
                    for oneRecord in singleRecord.values{
                       self.latitudeSet.append(oneRecord["locationLatitude"] as! CLLocationDegrees)
                       self.longitudeSet.append(oneRecord["locationLongitude"] as! CLLocationDegrees)
                       let str1: String = oneRecord["amount"] as! String
                       let str2: String = oneRecord["category"] as! String
                       self.titles.append(str1 + "$ for " + str2)
                      }
                }
                var i: Int = 0
                while(i < self.longitudeSet.count){
                    self.coordinateSet?.append(CLLocationCoordinate2D())
                    self.coordinateSet?[i].latitude = self.latitudeSet[i]
                    self.coordinateSet?[i].longitude = self.longitudeSet[i]
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // add
    func initCates() {
        self.curCate = Set(["Clothes", "Food", "Living", "Transport", "Others"])
        self.cateArray = Array(curCate).sorted()
        ref.child("Categories").child(self.uid).setValue(self.cateArray)
    }
    
    func fetchCate() {
        let CateUserRef = ref.child("Categories").child(self.uid)
        CateUserRef.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                // initialize if no category in database
                self.initCates()
                return
            }
            let curCateArray = snapshot.value as? [String] ?? []
            self.curCate = Set(curCateArray)
            guard self.curCate == [] else {
                self.initCates()
                return
            }
        })
    }
    
    func fetchData() {
        let userRecordsRef = self.ref.child("Records").child(self.uid)
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone.local
        self.recordsForChart = []
        
        userRecordsRef.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                return
            }
            let accountDict = snapshot.value as? NSDictionary ?? [:]
            for (_, accountValue) in accountDict{
                let recordDict = accountValue as? [String : [String : Any]] ?? [:]
                for (recordID, record) in recordDict {
                    let id = recordID
                    let account = record["accountNumber"] as? String ?? ""
                    let amountString = record["amount"] as? String ?? ""
                    let amount = Double(amountString) ?? 0
                    let category = record["category"] as? String ?? ""
                    let dateString = record["date"] as? String ?? ""
                    let date = formatter.date(from: dateString) ?? Date(timeIntervalSince1970: 0)
                    let imageURL = record["imageURL"] as? String ?? ""
                    let lat = record["locationLatitude"] as? CLLocationDegrees ?? 0
                    let long = record["locationLongitude"] as? CLLocationDegrees ?? 0
                    let note = record["note"] as? String ?? ""
                    self.recordsForChart.append(Record(id: id, account: account, amount: amount, category: category, date: date, long: long, lat: lat, imageURL: imageURL, note: note))
                }
            }
            self.updatePieChart()
        })
        return
    }
    
    func updatePieChart() {
        var subTotals: [String : Double] = [:]
        for name in cateArray {
            subTotals.updateValue(0, forKey: name)
        }
        self.thePieChart.chartDescription?.text = "Spending Structure"
        for record in recordsForChart {
            let category = record.category
            let amount = record.amount
            if self.curCate.contains(category) && record.date >= self.minDate && record.date <= self.maxDate {
                subTotals.updateValue(subTotals[category]! + amount, forKey: category)
            }
        }
        var dataEntries: [ChartDataEntry] = []
        var xNames: [String] = []
        for i in 0 ... self.cateArray.count - 1 {
            if subTotals[self.cateArray[i]]! == 0 { continue }
            let dataEntry = PieChartDataEntry(value: subTotals[self.cateArray[i]]!, label: self.cateArray[i])
            dataEntries.append(dataEntry)
            xNames.append(self.cateArray[i])
        }
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material() + [UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0)]
        let chartData =  PieChartData(dataSet: chartDataSet)
        chartData.setValueFormatter(self)
        self.thePieChart.data = chartData
        self.thePieChart.usePercentValuesEnabled = true
    }
}

extension statisticsController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return cateArray[Int(value)]
    }
}

extension statisticsController: IValueFormatter {
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        return "\(round(100 * value)/100)%"
    }
}

