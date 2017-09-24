//
//  BusinessCell.swift
//  Yelp
//
//  Created by Mandy Chen on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var ratingImageView: UIImageView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var reviewsCountLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!

  var business: Business! {
    didSet {
      nameLabel.text = business.name
      
      if let imageUrl = business.imageURL {
        thumbImageView.setImageWith(imageUrl)
      } else {
        thumbImageView.image = UIImage(named: "noThumbImage")
      }
      
      categoriesLabel.text = business.categories
      addressLabel.text = business.address
      reviewsCountLabel.text = "\(business.reviewCount!)Reviews"
      ratingImageView.setImageWith(business.ratingImageURL!)
      distanceLabel.text = business.distance
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    thumbImageView.layer.cornerRadius = 5
    thumbImageView.clipsToBounds = true
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

}
