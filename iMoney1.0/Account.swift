//
//  Account.swift
//  iMoney1.0
//
//  Created by John Han on 11/26/16.
//  Copyright © 2016 文静. All rights reserved.
//

import Foundation


struct Account {
    
    let id: String
    let AccountNumber: String
    let balance: String
    let owner: String
    
    init(id: String, AccountNumber: String, balance: String, owner: String) {
        self.id = id
        self.AccountNumber = AccountNumber
        self.balance = balance
        self.owner = owner
    }
    
}
