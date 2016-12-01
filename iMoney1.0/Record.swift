//
//  Record.swift
//  iMoney1.0
//
//  Created by 吕Mike on 11/30/16.
//  Copyright © 2016 文静. All rights reserved.
//

import Foundation
import MapKit

struct Record {
    
    let account: String
    let amount: Double
    let category: String
    let date: Date
    let long: CLLocationDegrees
    let lat: CLLocationDegrees
    let imageURL: String
    let note: String
    
    init(account: String, amount: Double, category: String, date: Date, long: CLLocationDegrees, lat: CLLocationDegrees, imageURL: String, note: String) {
        self.account = account
        self.amount = amount
        self.category = category
        self.date = date
        self.long = long
        self.lat = lat
        self.imageURL = imageURL
        self.note = note
    }
    
}
