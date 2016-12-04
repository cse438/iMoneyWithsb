//
//  ExtensionForTap.swift
//  iMoney1.0
//
//  Created by 吕Mike on 12/3/16.
//  Copyright © 2016 文静. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
