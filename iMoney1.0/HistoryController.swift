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

class HistoryController: UIViewController {
    
    @IBOutlet weak var theTable: UITableView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var spendingButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var spendings: [Record] = []
    var earnings: [Record] = []
    var formatter: DateFormatter! = nil
}
