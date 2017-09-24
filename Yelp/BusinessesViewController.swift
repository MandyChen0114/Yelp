//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate {
    
  var businesses: [Business]!
  var currSearch = (term: "", deals: false, distance: 0.0, sort: YelpSortMode.bestMatched, category: [String]())
  var pageOffSet = 0
  let distanceMeterMap = [0, 0.3 * 1609.34, 1609.34, 5 * 1609.34 , 20 * 1609.34]
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    
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

    Business.searchWithTerm(term: term, sort: sort, categories: categories, deals: deals, distance: distance, offset: pageOffSet) { (businesses: [Business]?, error:Error?) -> Void in
      self.businesses = businesses
      self.tableView.reloadData()
    }
  }


   // MARK: - Navigation
  
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
    let navigationController = segue.destination as! UINavigationController
    let filtersViewController = navigationController.topViewController as! FiltersViewController
    
    filtersViewController.delegate = self
    
    
   }

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    let categories = filters["categories"] as? [String]
    let deal = filters["deal"] as? Bool
    let distanceIndex = filters["distance"] as? Int
    
    search(term: "", sort: nil, categories: categories, deals: deal, distance: distanceMeterMap[distanceIndex!])
  }
    
}
