//
//  ZHUserCollectionViewCell.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 12/13/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class ZHUserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    
    var user: ZHUser? = nil {
        didSet{
            statusLabel.text = "user: " + (user?.username)!
        }
    }
}
