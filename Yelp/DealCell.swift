//
//  DealCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol DealCellDelegate {
  @objc optional func dealCell(dealCell: DealCell, didChangeValue:Bool)
}

class DealCell: UITableViewCell {

  @IBOutlet weak var dealLabel: UILabel!
  @IBOutlet weak var dealSwitch: DesignableSwitch!
  @IBOutlet weak var switchView: UIView!
  
  weak var dealDelegate:DealCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    switchView.layer.cornerRadius = 5
    switchView.layer.borderColor = UIColor.darkGray.cgColor
    switchView.layer.borderWidth = 0.3

    dealSwitch.thumbTintColor = UIColor.init(patternImage: UIImage(named: "yelpIcon")!)
    dealSwitch.addTarget(self, action: #selector(DealCell.dealValueChanged), for: UIControlEvents.valueChanged)
  }

  func dealValueChanged() {
    dealDelegate?.dealCell?(dealCell: self, didChangeValue: dealSwitch.isOn)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
