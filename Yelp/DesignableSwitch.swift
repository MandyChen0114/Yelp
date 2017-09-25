//
//  designableSwitch.swift
//  Yelp
//
//  Created by Mandy Chen on 9/24/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableSwitch: UISwitch {
  @IBInspectable var thumbImage: UIImage? {
    didSet {
      thumbTintColor = UIColor.init(patternImage: thumbImage!)
    }
  }
  
}
