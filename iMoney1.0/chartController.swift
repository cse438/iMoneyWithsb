//
//  chartController.swift
//  iMoney1.0
//
//  Created by 吕Mike on 11/27/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Charts

class chartController: UIViewController {
    
    @IBOutlet weak var thePieChart: PieChartView!
    @IBOutlet weak var theMinDatePicker: UIDatePicker!
    @IBOutlet weak var theMaxDatePicker: UIDatePicker!
    
    var ref: FIRDatabaseReference!
    var currentUser: FIRUser!
    var minDate: Date = Date()
    var maxDate: Date = Date()
    var calendar: Calendar! = nil
    var records: [Record] = []
    var cateArray: [String] = []
    var curCate: Set<String> = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = FIRDatabase.database().reference()
        currentUser = FIRAuth.auth()?.currentUser
        initCates()
        fetchCate()
        fetchData()
        
        self.calendar = Calendar.current
        self.calendar.timeZone = NSTimeZone.local
        theMinDatePicker.date = Date()
        theMaxDatePicker.date = Date()
        theMinDatePicker.datePickerMode = .date
        theMaxDatePicker.datePickerMode = .date
        theMinDatePicker.minimumDate = Date(timeIntervalSince1970: 0)
        theMinDatePicker.maximumDate = theMaxDatePicker.date
        theMaxDatePicker.minimumDate = theMinDatePicker.date
        theMaxDatePicker.maximumDate = Date()
        let startOfToday = calendar.startOfDay(for: Date())
        let lastMinOfToday = calendar.date(byAdding: .minute, value: 1439, to: Date())!
        let endOfToday = calendar.date(byAdding: .second, value: 59, to: lastMinOfToday)!
        self.minDate = startOfToday
        self.maxDate = endOfToday
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func minPickerChanged(_ sender: Any) {
        theMaxDatePicker.minimumDate = theMinDatePicker.date
        minDate = theMinDatePicker.date
        updatePieChart()
    }
    
    @IBAction func maxPickerChanged(_ sender: Any) {
        theMinDatePicker.maximumDate = theMaxDatePicker.date
        let startOfDay = theMaxDatePicker.date
        var dateAtEnd = calendar.date(byAdding: .minute, value: 1439, to: startOfDay)
        dateAtEnd = calendar.date(byAdding: .second, value: 59, to: dateAtEnd!)
        maxDate = dateAtEnd!
        updatePieChart()
    }
    
    func initCates() {
        self.curCate = Set(["Clothes", "Food", "Living", "Transport", "Others"])
        self.cateArray = Array(curCate).sorted()
        ref.child("Categories").child(self.currentUser.uid).setValue(self.cateArray)
    }
    
    
    func fetchCate() {
        let CateUserRef = ref.child("Categories").child(self.currentUser.uid)
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
        let userRecordsRef = self.ref.child("Records").child(currentUser.uid)
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = NSTimeZone.local
        self.records = []
        
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
                    self.records.append(Record(id: id, account: account, amount: amount, category: category, date: date, long: long, lat: lat, imageURL: imageURL, note: note))
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
        for record in records {
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension chartController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return cateArray[Int(value)]
    }
}

extension chartController: IValueFormatter {
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        return "\(round(100 * value)/100)%"
    }
}
