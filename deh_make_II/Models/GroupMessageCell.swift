//
//  GroupMessageCell.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/11/29.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import Foundation
import UIKit

class GroupMessageCell: UITableViewCell {
    @IBOutlet weak var messageLable: UILabel!
    
    @IBOutlet weak var agreeButton:  UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
