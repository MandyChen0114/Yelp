//
//  CheckBoxCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol CheckBoxCellDelegate {
  @objc optional func checkboxCell(checkboxCell: CheckBoxCell, didChangeValue:Bool)
}

class CheckBoxCell: UITableViewCell {
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var checkBoxView: UIView!
  @IBOutlet weak var button: UIButton!
  
  weak var checkboxDelegate:CheckBoxCellDelegate?
  
  let uncheckedImage = UIImage(named: "uncheckedBox")
  let checkedImage = UIImage(named: "checkedBox")
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    checkBoxView.layer.cornerRadius = 5
    checkBoxView.layer.borderColor = UIColor.darkGray.cgColor
    checkBoxView.layer.borderWidth = 0.3

    button.setImage(uncheckedImage, for: UIControlState.normal)
    button.addTarget(self, action: #selector(CheckBoxCell.checkboxValueChanged), for: UIControlEvents.touchUpInside)
  
  }

  func checkboxValueChanged() {
    var isSelected = false
    if button.currentImage == uncheckedImage {
      button.setImage(checkedImage, for: UIControlState.normal)
      isSelected = true
    } else {
      button.setImage(uncheckedImage, for: UIControlState.normal)
      isSelected = false
    }
    
    checkboxDelegate?.checkboxCell?(checkboxCell: self, didChangeValue: isSelected)
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
