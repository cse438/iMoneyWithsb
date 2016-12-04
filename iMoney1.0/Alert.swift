//
//  Alert.swift
//  iMoney1.0
//
//  Created by 吕Mike on 12/4/16.
//  Copyright © 2016 文静. All rights reserved.
//

import Foundation
import UIKit

class Alert {
    
    var title: String
    var message: String
    var target: UIViewController?
    
    init(title: String, message: String, target: UIViewController?) {
        self.title = title
        self.message = message
        self.target = target
    }
    
    func show() {
        let signInAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default)
        signInAlert.addAction(dismissAction)
        if target == nil { return }
        target!.present(signInAlert, animated: true, completion: nil)
    }
    
    
}
