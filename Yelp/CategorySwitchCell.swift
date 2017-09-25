//
//  CategorySwitchCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol CategorySwitchCellDelegate {
  @objc optional func categorySwitchCell(categorySwitchCell: CategorySwitchCell, didChangeValue: Bool)
}


class CategorySwitchCell: UITableViewCell {

  @IBOutlet weak var onSwitch: DesignableSwitch!
  @IBOutlet weak var switchLabel: UILabel!
  
  weak var delegate:CategorySwitchCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    onSwitch.thumbTintColor = UIColor.init(patternImage: UIImage(named: "yelpIcon")!)
    onSwitch.addTarget(self, action: #selector(CategorySwitchCell.switchValueChanged), for: UIControlEvents.valueChanged)
    
  }
  
  func switchValueChanged() {
    delegate?.categorySwitchCell?(categorySwitchCell: self, didChangeValue: onSwitch.isOn)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
