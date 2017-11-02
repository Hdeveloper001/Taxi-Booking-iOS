//
//  PickLocationTBCell.swift
//  hitchcabs
//
//  Created by iOSpro on 11/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class PickLocationTBCell: UITableViewCell {
    
    @IBOutlet var icon_pickup: UIImageView!
    @IBOutlet var icon_process: UIImageView!
    @IBOutlet var icon_action: UIImageView!
    
    @IBOutlet var lb_pickupTitle: UILabel!
    @IBOutlet var lb_pickupLocation: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
