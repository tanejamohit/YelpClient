//
//  FilterViewCell.swift
//  Yelp
//
//  Created by Mohit Taneja on 9/23/17.
//  Copyright © 2017 Mohit Taneja. All rights reserved.
//

import UIKit
import SevenSwitch

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
  @IBOutlet weak var expandableImageView: UIImageView!
  @IBOutlet weak var seeAllLabel: UILabel!
  @IBOutlet weak var switchView: UIView!
  
  var filterSwitch: SevenSwitch = SevenSwitch()
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
    tapRecognizerForExpandableImageView.cancelsTouchesInView = true;
    self.addGestureRecognizer(tapRecognizerForExpandableImageView)

    self.switchView.addSubview(filterSwitch)

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
    updateSwitchStyle()
  }
  
  func updateSwitchStyle() {
    if (cellType == FilterViewCellType.Normal || cellType == FilterViewCellType.ExpandableExpanded) {
      filterSwitch.thumbTintColor = UIColor(red: 0.69, green: 0.73, blue: 0.83, alpha: 1)
      filterSwitch.activeColor =  UIColor.white
      filterSwitch.inactiveColor =  UIColor.white
      filterSwitch.onTintColor =  UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1)
      filterSwitch.borderColor = UIColor(red: 0.85, green: 0.1, blue: 0.1, alpha: 1)
      filterSwitch.shadowColor = UIColor.black
      filterSwitch.frame = CGRect(x: 0, y: 0, width: 60, height: 25)
    }
  }
  
  @IBAction func switchValueChanged(_ sender: Any) {
    delegate?.FilterViewCell?(filterViewCell: self, didChangeValue: filterSwitch.on)
  }
  
  @IBAction func tapGestureRecognizerTapped(_ sender: Any) {
    if cellType == FilterViewCellType.ExpandableNotExpanded ||
      cellType == FilterViewCellType.ShowAll{
      delegate?.FilterViewCell?(filterViewCell: self, didChangeValue: filterSwitch.on)
    }
    else if cellType == FilterViewCellType.Normal ||
      cellType == FilterViewCellType.ExpandableExpanded {
      filterSwitch.setOn(!filterSwitch.on, animated: true)
      delegate?.FilterViewCell?(filterViewCell: self, didChangeValue: filterSwitch.on)
    }
  }
}

