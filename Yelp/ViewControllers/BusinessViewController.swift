//
//  ViewController.swift
//  Yelp
//
//  Created by Mohit Taneja on 9/20/17.
//  Copyright © 2017 Mohit Taneja. All rights reserved.
//

import UIKit

class BusinessViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersViewControllerDelegate, UIScrollViewDelegate {
  
  @IBOutlet weak var businessTableView: UITableView!
  @IBOutlet var tapGestureRecornizer: UITapGestureRecognizer!
  
  var businesses: [Business] = []
  var searchBar:UISearchBar!
  var filter:Filter = Filter()
  var isMoreDataLoading = false
  var loadingMoreView:InfiniteScrollActivityView?
  let NUM_SEARCH_RESULTS_TO_LOAD: Int = 20
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Initialize the table view
    businessTableView.dataSource = self
    businessTableView.delegate = self
    businessTableView.rowHeight = UITableViewAutomaticDimension
    businessTableView.estimatedRowHeight = 120
    
    // Initialize the UISearchBar
    searchBar = UISearchBar()
    searchBar.delegate = self
    
    // Add SearchBar to the NavigationBar
    searchBar.sizeToFit()
    navigationItem.titleView = searchBar
    searchBar.tintColor = UIColor.white
    searchBar.placeholder = "Restaurants"
    
    // Add Scroll Loading view for infinite scrolling
    let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.isHidden = true
    businessTableView.addSubview(loadingMoreView!)
    
    var insets = businessTableView.contentInset
    insets.bottom += InfiniteScrollActivityView.defaultHeight
    businessTableView.contentInset = insets

    
    // Perform the first search when the view controller first loads
    doSearch(searchString: "Restaurants", useOffset: false)
    
  }
  
  func doSearch(searchString: String, useOffset: Bool) {
    // Do any additional setup after loading the view, typically from a nib.
    var offset:Int = 0
    if useOffset {
      offset = businesses.count
    }
    Business.searchWithTerm(term: searchString, filter: filter, limit:NUM_SEARCH_RESULTS_TO_LOAD,  offset:offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
      if businesses != nil {
        if useOffset {
          self.businesses.append(contentsOf: businesses!)
        } else {
          self.businesses = businesses!
        }
        self.businessTableView.reloadData()
      }
      self.isMoreDataLoading = false
      self.loadingMoreView!.stopAnimating()
    }
    )
  }
  
  // Hide search bar keyboard
  @IBAction func hideKeyboard(_ sender: Any) {
    searchBar.resignFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK:- Table View functions
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return businesses.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessViewCell", for: indexPath) as! BusinessViewCell
    
    let business = businesses[indexPath.row]
    cell.business = business
    
    return cell
  }
  
  // MARK:- Search view functions
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(true, animated: true)
    return true
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(false, animated: true)
    return true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    doSearch(searchString: searchBar.text!, useOffset: false)
    searchBar.resignFirstResponder()
  }
  
  // MARK:- FilterViewControllerDelegate
  func FiltersViewController(FiltersViewController: FiltersViewController, didChangeFilters filter: Filter) {
    self.filter = filter
    doSearch(searchString: searchBar.text!, useOffset: false)
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let navigationController = segue.destination as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    filtersViewController.filter = filter
    filtersViewController.delegate = self
  }
  
  // MARK:- Scroll view functions
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      // Calculate the position of one screen length before the bottom of the results
      let scrollViewContentHeight = businessTableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - 2*businessTableView.bounds.size.height
      
      // When the user has scrolled past the threshold, start requesting
      if(scrollView.contentOffset.y > scrollOffsetThreshold &&
        businessTableView.isDragging &&
        businesses.count >= NUM_SEARCH_RESULTS_TO_LOAD) {
        
        // Update position of loadingMoreView, and start loading indicator
        let frame = CGRect(x: 0, y: businessTableView.contentSize.height, width: businessTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()

        isMoreDataLoading = true
        loadMoreData()
      }
    }
  }
  
  func loadMoreData() {
      doSearch(searchString: searchBar.text!, useOffset: true)
  }

  
  
}

