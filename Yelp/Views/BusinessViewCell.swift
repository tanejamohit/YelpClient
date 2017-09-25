//
//  BusinessViewCell.swift
//  Yelp
//
//  Created by Mohit Taneja on 9/22/17.
//  Copyright © 2017 Mohit Taneja. All rights reserved.
//

import UIKit

class BusinessViewCell: UITableViewCell {
  
  
  @IBOutlet weak var businessName: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var dollarLabel: UILabel!
  @IBOutlet weak var reviewLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoriesLabel: UILabel!
  @IBOutlet weak var starsImageView: UIImageView!
  @IBOutlet weak var businessImageView: UIImageView!
  
  var business: Business? {
    didSet {
      businessName.text = business?.name
      distanceLabel.text = business?.distance
      reviewLabel.text = "\(String(describing: business?.reviewCount as! Int)) Reviews"
      addressLabel.text = business?.address
      categoriesLabel.text = business?.categories
      if let starsImageUrl: URL = business?.ratingImageURL {
        starsImageView.setImageWith(starsImageUrl)
      }
      if let businessImageUrl: URL = business?.imageURL {
        businessImageView.setImageWith(businessImageUrl)
      }
    }
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

