//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Mohit Taneja on 9/23/17.
//  Copyright © 2017 Mohit Taneja. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate {
  func FiltersViewController(FiltersViewController: FiltersViewController, didChangeFilters filter:Filter)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FilterViewCellDelegate {
  
  @IBOutlet weak var searchButton: UIBarButtonItem!
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!
  
  let NUM_CELLS_FOR_FOLDED_CATEGORIES:Int = 4
  
  var filter:Filter = Filter()
  var delegate:FiltersViewControllerDelegate?
  
  // The structure of table in terms of sections and cells
  var tableSectionDefinition:[[String:Any]] = [["name":"",
                                                "sectionCellType":FilterViewCellType.Normal,
                                                "cells": ["Offering a Deal"]],
                                               ["name":"Distance",
                                                "sectionCellType":FilterViewCellType.ExpandableNotExpanded,
                                                "cells": [["name":"Auto", "value":0.0],
                                                          ["name":"0.3 miles", "value":0.3],
                                                          ["name":"1 mile", "value":1.0],
                                                          ["name":"5 miles", "value":5.0],
                                                          ["name":"20 miles", "value":20.0]]],
                                               ["name":"Sort By",
                                                "sectionCellType":FilterViewCellType.ExpandableNotExpanded,
                                                "cells": [["name":"Best Match", "value":YelpSortMode.bestMatched],
                                                          ["name":"Distance", "value":YelpSortMode.distance],
                                                          ["name":"Highest Rated", "value":YelpSortMode.highestRated]]],
                                               ["name":"Category",
                                                "sectionCellType":FilterViewCellType.ShowAll]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK:- Navigation Controls
  @IBAction func onCancelledButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onSearchButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    delegate?.FiltersViewController(FiltersViewController: self, didChangeFilters: filter)
  }
  
  // MARK:- Table View functions
  public func numberOfSections(in tableView: UITableView) -> Int {
    return tableSectionDefinition.count
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 80))
    headerView.backgroundColor = UIColor(white: 1.0, alpha: 1)
    
    // Add a UILabel for the name of the section here
    let label = UILabel(frame: CGRect(x: 10, y: 20, width: 240, height: 30))
    label.text = tableSectionDefinition[section]["name"] as? String
    label.textColor = UIColor.black
    label.textAlignment = NSTextAlignment.left
    label.font = UIFont.boldSystemFont(ofSize: 17)
    headerView.addSubview(label)
    
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return (tableSectionDefinition[section]["name"] as! String=="") ? 30 : 60
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var numOfCells:Int
    switch tableSectionDefinition[section]["sectionCellType"] as! FilterViewCellType {
    case FilterViewCellType.Normal:
      numOfCells = (tableSectionDefinition[section]["cells"] as! [String]).count
    case FilterViewCellType.ExpandableNotExpanded:
      numOfCells = 1
    case FilterViewCellType.ExpandableExpanded:
      numOfCells = (tableSectionDefinition[section]["cells"] as! [[String:Any]]).count
    case FilterViewCellType.ShowAll:
      numOfCells = NUM_CELLS_FOR_FOLDED_CATEGORIES
    case FilterViewCellType.ShowAllExpanded:
      numOfCells = filter.categories.count
    }
    return numOfCells
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "FilterViewCell", for: indexPath) as! FilterViewCell
    
    // Design the table cell based on
    switch tableSectionDefinition[indexPath.section]["sectionCellType"] as! FilterViewCellType {
      
    case FilterViewCellType.Normal:
      cell.filterName.text = (tableSectionDefinition[indexPath.section]["cells"] as! [String])[indexPath.row] as String
      cell.cellType = FilterViewCellType.Normal
      cell.filterSwitch.on = filter.filterByDeal!
      
    case FilterViewCellType.ExpandableNotExpanded:
      // When the Expandable type is folded we want to show
      // the text for the cell which was last selected
      let selectedRow:Int = getSelectedRowForSection(section: indexPath.section)
      cell.filterName.text = ((tableSectionDefinition[indexPath.section]["cells"] as! [[String:Any]])[selectedRow])["name"] as? String
      cell.cellType = FilterViewCellType.ExpandableNotExpanded
      
    case FilterViewCellType.ExpandableExpanded:
      let selectedRow:Int = getSelectedRowForSection(section: indexPath.section)
      cell.filterName.text = ((tableSectionDefinition[indexPath.section]["cells"] as! [[String:Any]])[indexPath.row])["name"] as? String
      cell.cellType = FilterViewCellType.ExpandableExpanded
      cell.filterSwitch.on = (indexPath.row == selectedRow) ? true : false

    case FilterViewCellType.ShowAll:
      // If this section hasn't been expanded yet and the index is the last row
      // make this showAll cell
      if (indexPath.row == NUM_CELLS_FOR_FOLDED_CATEGORIES-1)  {
        cell.cellType = FilterViewCellType.ShowAll
      }
      else {
        cell.filterName.text = filter.categories[indexPath.row]["name"] as? String
        cell.cellType = FilterViewCellType.Normal
        cell.filterSwitch.on = (filter.categories[indexPath.row]["enabled"] as? Bool)!
      }
      
    case FilterViewCellType.ShowAllExpanded:
      cell.filterName.text = filter.categories[indexPath.row]["name"] as? String
      cell.cellType = FilterViewCellType.Normal
      cell.filterSwitch.on = (filter.categories[indexPath.row]["enabled"] as? Bool)!
    }
    
    cell.delegate = self
    return cell
  }
  
  func getSelectedRowForSection (section:Int)->Int  {
    let numCells:Int = (tableSectionDefinition[section]["cells"] as! [[String:Any]]).count
    
    // Check for Distance
    if(section == 1) {
      for row in 0..<numCells {
        let cell:[String:Any] = (tableSectionDefinition[section]["cells"] as! [[String:Any]])[row]
        if (cell["value"] as? NSNumber)?.floatValue == filter.distance {
          return row
        }
      }
    }
    
      // Check for SortMethod
    else if(section == 2) {
      for row in 0..<numCells {
        let cell:[String:Any] = (tableSectionDefinition[section]["cells"] as! [[String:Any]])[row]
        if cell["value"] as? YelpSortMode == filter.sortType {
          return row
        }
      }
    }
    
    return 0
  }
  
  // MARK:- Filter Cell Delegate
  
  func FilterViewCell(filterViewCell: FilterViewCell, didChangeValue value: Bool) {
    
    let indexPath:IndexPath = tableView.indexPath(for: filterViewCell)!
    let section:Int = indexPath.section
    
    switch section {
      
    case 0:
      // We know the first section is simply filter by deal
      filter.filterByDeal = filterViewCell.filterSwitch.on
      
    case 1:
      // Either we were expanded or one of the options was selected
      let sectionCellType:FilterViewCellType = tableSectionDefinition[indexPath.section]["sectionCellType"] as! FilterViewCellType
      
      if (sectionCellType == FilterViewCellType.ExpandableNotExpanded) {
        // Simply expand the section
        tableSectionDefinition[section]["sectionCellType"] = FilterViewCellType.ExpandableExpanded
      }
      else  if (sectionCellType == FilterViewCellType.ExpandableExpanded) {
        filter.distance = (((tableSectionDefinition[section]["cells"] as! [[String:Any]])[indexPath.row])["value"] as? NSNumber)?.floatValue
        tableSectionDefinition[section]["sectionCellType"] = FilterViewCellType.ExpandableNotExpanded
      }
      tableView.reloadSections(IndexSet (integer: 1), with: .automatic)

    case 2:
      // Either we were expanded or one of the options was selected
      let sectionCellType:FilterViewCellType = tableSectionDefinition[indexPath.section]["sectionCellType"] as! FilterViewCellType
      
      if (sectionCellType == FilterViewCellType.ExpandableNotExpanded) {
        // Simply expand the section
        tableSectionDefinition[section]["sectionCellType"] = FilterViewCellType.ExpandableExpanded
      }
      else  if (sectionCellType == FilterViewCellType.ExpandableExpanded) {
        filter.sortType = ((tableSectionDefinition[section]["cells"] as! [[String:Any]])[indexPath.row])["value"] as? YelpSortMode
        tableSectionDefinition[section]["sectionCellType"] = FilterViewCellType.ExpandableNotExpanded
      }
      tableView.reloadSections(IndexSet (integer: 2), with: .automatic)

    case 3:
      if filterViewCell.cellType == FilterViewCellType.ShowAll {
        tableSectionDefinition[section]["sectionCellType"] = FilterViewCellType.ShowAllExpanded
        tableView.reloadSections(IndexSet (integer: 3), with: .automatic)
      }
      else if filterViewCell.cellType == FilterViewCellType.Normal {
        filter.categories[indexPath.row]["enabled"] = filterViewCell.filterSwitch.on
      }
    default: ()
    }
  }
  
  
}

