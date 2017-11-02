//
//  FavouriteTBCell.swift
//  hitchcabs
//
//  Created by iOSpro on 14/10/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit

class FavouriteTBCell: UITableViewCell {
    
    @IBOutlet var lb_title: UILabel!
    
    @IBOutlet var lb_location: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
