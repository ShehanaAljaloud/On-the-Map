//
//  ListViewCell.swift
//  On The Map
//
//  Created by Shehana Aljaloud on 10/06/2019.
//  Copyright © 2019 Shehana Aljaloud. All rights reserved.
//

import UIKit

class ListViewCell: UITableViewCell  {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var URLLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
