//
//  user.swift
//  iMoney1.0
//
//  Created by John Han on 11/20/16.
//  Copyright © 2016 文静. All rights reserved.
//

import Foundation


struct User {
    
    let uid: String
    let email: String
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
