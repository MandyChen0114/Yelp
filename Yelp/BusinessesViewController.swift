//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchResultsUpdating, UIScrollViewDelegate {
  
  let DEFAULT_DEAL = false
  let DEFAULT_DISTANCE_ROW_INDEX = 0
  let DEFAULT_SORT_BY_ROW_INDEX = 0
  let DEFAULT_CATEGORY_STATES = [Int:Bool]()
  
  var businesses: [Business]!
  var currSearch = (term: "", deals: false, distance: 0.0, sort: YelpSortMode.bestMatched, category: [String]())
  var currFilters = (deal: false, distanceRowIndex: 0, sortByRowIndex: 0, categoryStates:[Int:Bool]())
  var pageOffSet = 0
  let distanceMeterMap = [0, 0.3 * 1609.34, 1609.34, 5 * 1609.34 , 20 * 1609.34]
  var searchController: UISearchController!
  var isMoreDataLoading = false
  var loadingMoreView:InfiniteScrollActivityView?

  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    tableView.setContentOffset(CGPoint.zero, animated: false)
    
    initSearchBar()
    initInfiniteScroll()
    
    search(term: "", sort: nil, categories: nil, deals: nil, distance: nil)
  }
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if businesses != nil {
      return businesses!.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
    
    cell.business = businesses[indexPath.row]
    
    return cell
  }

  func search(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Double? ) {
    currSearch.term = term
    currSearch.sort = sort ?? YelpSortMode.bestMatched
    currSearch.deals = deals ?? false
    currSearch.distance = distance ?? 0
    currSearch.category = categories ?? [String]()
    
    Business.searchWithTerm(term: term, sort: sort, categories: categories, deals: deals, distance: distance, offset: pageOffSet) { (businesses: [Business]?, error:Error?) -> Void in
      if self.pageOffSet > 0 && (businesses?.count)! > 0 {
        for business in businesses! {
          self.businesses.append(business)
        }
        
      } else {
        self.businesses = businesses
      }
      self.isMoreDataLoading = false
      self.tableView.reloadData()
      self.loadingMoreView!.stopAnimating()
    }
  }

  
  // MARK: - Search
  func initSearchBar() {
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    
    searchController.dimsBackgroundDuringPresentation = false
    searchController.hidesNavigationBarDuringPresentation = false
    
    searchController.searchBar.sizeToFit()
    navigationItem.titleView = searchController.searchBar
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    pageOffSet = 0
    if let keyword = searchController.searchBar.text {
      Business.searchWithTerm(term: keyword, completion: { (businesses:[Business]?, error: Error?) in
        self.businesses = businesses
        self.tableView.reloadData()

      })
    }
  
  }

  // MARK: - Infinite Scrolling
  
  func initInfiniteScroll() {
    // Set up Infinite Scroll loading indicator
    let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.isHidden = true
    tableView.addSubview(loadingMoreView!)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (!isMoreDataLoading) {
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
        isMoreDataLoading = true
        
        let frame = CGRect(x:0,y: tableView.contentSize.height, width: tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
        
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
        
        pageOffSet += 20
        
        search(term: currSearch.term, sort: currSearch.sort, categories: currSearch.category, deals: currSearch.deals, distance: currSearch.distance)
      }
    }
  }
  
  
  // MARK: - Navigation

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let navigationController = segue.destination as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    
    filtersViewController.currFilters = currFilters
    filtersViewController.delegate = self
  }

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    pageOffSet = 0
    tableView.setContentOffset(CGPoint.zero, animated: false)
    let categories = filters["categories"] as? [String]
    let deal = filters["deal"] as? Bool
    let distanceIndex = filters["distance"] as? Int
    let sortMode = filters["sortBy"] as? Int
    let categoryStates =  filters["categoryStates"] as? [Int: Bool]
    
    currFilters.deal = deal ?? DEFAULT_DEAL
    currFilters.distanceRowIndex = distanceIndex ?? DEFAULT_DISTANCE_ROW_INDEX
    currFilters.sortByRowIndex = sortMode ?? DEFAULT_SORT_BY_ROW_INDEX
    currFilters.categoryStates = categoryStates ?? DEFAULT_CATEGORY_STATES
    
    search(term: "", sort: sortMode.map { YelpSortMode(rawValue: $0) }!, categories: categories, deals: deal, distance: distanceMeterMap[distanceIndex!])
  }
    
}
