//
//  GooglePlacesTableViewCell.swift
//  DogOutMap
//
//  Created by Water Flower on 2019/1/30.
//  Copyright © 2019 Water Flower. All rights reserved.
//

import UIKit

class GooglePlacesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var placenameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
