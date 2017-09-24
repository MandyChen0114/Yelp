//
//  DistanceCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol DistanceCellDelegate {
  @objc optional func distanceCell(distanceCell: DistanceCell, didChangeValue:Bool)
}

class DistanceCell: UITableViewCell {

  @IBOutlet weak var label: UILabel!
  
  @IBOutlet weak var button: UIButton!
  weak var distanceDelegate:DistanceCellDelegate?
  
  let uncheckedImage = UIImage(named: "uncheckedBox")
  let checkedImage = UIImage(named: "checkedBox")
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    button.setImage(uncheckedImage, for: UIControlState.normal)
    button.addTarget(self, action: #selector(DistanceCell.distanceValueChanged), for: UIControlEvents.touchUpInside)
  
  }

  func distanceValueChanged() {
    var isSelected = false
    if button.currentImage == uncheckedImage {
      button.setImage(checkedImage, for: UIControlState.normal)
      isSelected = true
    } else {
      button.setImage(uncheckedImage, for: UIControlState.normal)
      isSelected = false
    }
    
    distanceDelegate?.distanceCell?(distanceCell: self, didChangeValue: isSelected)
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
