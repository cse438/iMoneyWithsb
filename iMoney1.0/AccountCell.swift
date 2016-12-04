//
//  accountCell.swift
//  iMoney1.0
//
//  Created by 吕Mike on 11/20/16.
//  Copyright © 2016 文静. All rights reserved.
//

import UIKit

class AccountCell: UICollectionViewCell {
    
    
    @IBOutlet weak var theImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var closeImage: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
