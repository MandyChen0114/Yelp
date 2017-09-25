//
//  DropDownCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class DropDownCell: UITableViewCell {

  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var dropDownView: UIView!
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
      dropDownView.layer.cornerRadius = 5
      dropDownView.layer.borderColor = UIColor.darkGray.cgColor
      dropDownView.layer.borderWidth = 0.3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
