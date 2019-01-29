//
//  ReportsTableViewCell.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/28.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class ReportsTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        commentLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
