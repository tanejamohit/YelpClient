//
//  FilterViewCell.swift
//  Yelp
//
//  Created by Mohit Taneja on 9/23/17.
//  Copyright © 2017 Mohit Taneja. All rights reserved.
//

import UIKit

enum FilterViewCellType {
  case Normal
  case ExpandableExpanded
  case ExpandableNotExpanded
  case ShowAll
  case ShowAllExpanded
}

@objc protocol FilterViewCellDelegate {
  @objc optional func FilterViewCell(filterViewCell: FilterViewCell, didChangeValue value:Bool)
}


class FilterViewCell: UITableViewCell {
  
  @IBOutlet weak var filterName: UILabel!
  @IBOutlet weak var filterSwitch: UISwitch!
  @IBOutlet weak var expandableImageView: UIImageView!
  @IBOutlet weak var seeAllLabel: UILabel!
  
  var delegate: FilterViewCellDelegate?
  var cellType: FilterViewCellType? {
    didSet {
      configureCellForType()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // Add tap gesture recognizer for expandable image and show all
    let tapRecognizerForExpandableImageView = UITapGestureRecognizer(target: self, action: #selector(FilterViewCell.tapGestureRecognizerTapped(_:)))
    self.addGestureRecognizer(tapRecognizerForExpandableImageView)

  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  // Configure the cell if its type is set/changed
  func configureCellForType() {
    switch self.cellType! {
    
    case FilterViewCellType.Normal:
      expandableImageView.isHidden = true
      seeAllLabel.isHidden = true
      filterName.isHidden = false
      filterSwitch.isHidden = false
    
    case FilterViewCellType.ExpandableNotExpanded:
      expandableImageView.isHidden = false
      seeAllLabel.isHidden = true
      filterName.isHidden = false
      filterSwitch.isHidden = true
      
    case FilterViewCellType.ExpandableExpanded:
      expandableImageView.isHidden = true
      seeAllLabel.isHidden = true
      filterName.isHidden = false
      filterSwitch.isHidden = false

    case FilterViewCellType.ShowAll:
      expandableImageView.isHidden = true
      seeAllLabel.isHidden = false
      filterName.isHidden = true
      filterSwitch.isHidden = true

    case FilterViewCellType.ShowAllExpanded:
      expandableImageView.isHidden = true
      seeAllLabel.isHidden = true
      filterName.isHidden = false
      filterSwitch.isHidden = false

    }
  }
  
  @IBAction func switchValueChanged(_ sender: Any) {
    delegate?.FilterViewCell?(filterViewCell: self, didChangeValue: filterSwitch.isOn)
  }
  
  @IBAction func tapGestureRecognizerTapped(_ sender: Any) {
    if cellType == FilterViewCellType.ExpandableNotExpanded ||
      cellType == FilterViewCellType.ShowAll{
      delegate?.FilterViewCell?(filterViewCell: self, didChangeValue: filterSwitch.isOn)
    }
  }
}

