//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Mandy Chen on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
  @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategorySwitchCellDelegate, DealCellDelegate, CheckBoxCellDelegate {
  @IBOutlet weak var tableView: UITableView!

  var sections: [[String: Any]] = []
  var categories: [[String: String]] = []
  var currFilters: (deal: Bool, distanceRowIndex: Int, sortByRowIndex: Int, categoryStates:[Int:Bool])!
  
  var categorySwitchStates = [Int:Bool]()
  var dealSwitchState : Bool = false
  var distanceStates = (selectedRowIndex: 0, selectedRowLabel: "Auto")
  var sortByStates = (selectedRowIndex: 0, selectedRowLabel: "Best Match")
  
  var isDistanceExpanded = false
  var isSortByExpanded = false
  var isCategoryExpanded = false
  
  let uncheckedImage = UIImage(named: "uncheckedBox")
  let checkedImage = UIImage(named: "checkedBox")
  
  let DEAL_SECTION_INDEX = 0
  let DISTANCE_SECTION_INDEX = 1
  let SORT_BY_SECTION_INDEX = 2
  let CATEGORY_SECTION_INDEX = 3
  
  weak var delegate:FiltersViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 45
    
    categories = yelpCategories()
    sections = sectionData()
    
    if currFilters != nil {
      dealSwitchState = currFilters.deal
      distanceStates.selectedRowIndex = currFilters.distanceRowIndex
      distanceStates.selectedRowLabel = getLabelByIndexPath(section: DISTANCE_SECTION_INDEX, row: distanceStates.selectedRowIndex)
      sortByStates.selectedRowIndex = currFilters.sortByRowIndex
      sortByStates.selectedRowLabel = getLabelByIndexPath(section: SORT_BY_SECTION_INDEX, row: sortByStates.selectedRowIndex)
      categorySwitchStates = currFilters.categoryStates
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    
  @IBAction func onCancelButton(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onSearchButton(_ sender: Any) {
    var filters = [String : AnyObject]()
    var selectedCategories = [String]()
    
    for (row,isSelected) in categorySwitchStates {
      if(isSelected){
        selectedCategories.append(categories[row]["code"]!)
      }
    }
    
    if selectedCategories.count > 0 {
      filters["categories"] = selectedCategories as AnyObject?
    }
    filters["categoryStates"] = categorySwitchStates as AnyObject?
    filters["deal"] = dealSwitchState as AnyObject?
    filters["distance"] = distanceStates.selectedRowIndex as AnyObject?
    filters["sortBy"] = sortByStates.selectedRowIndex as AnyObject?
    
    delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    dismiss(animated: true, completion: nil)
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  func isDistanceCollapsed(section: Int) -> Bool {
    return section == DISTANCE_SECTION_INDEX && !isDistanceExpanded
  }
  
  func isSortByCollapsed(section: Int) -> Bool {
    return section == SORT_BY_SECTION_INDEX && !isSortByExpanded
  }

  func isCategoryCollapsed(section: Int) -> Bool {
    return section == CATEGORY_SECTION_INDEX && !isCategoryExpanded
  }

  func isCheckBoxCell(section: Int) -> Bool {
    return section == DISTANCE_SECTION_INDEX || section == SORT_BY_SECTION_INDEX
  }

  func isSelectedCheckBoxCell(indexPath: IndexPath) -> Bool {
    return (DISTANCE_SECTION_INDEX == indexPath.section && distanceStates.selectedRowIndex == indexPath.row) || (SORT_BY_SECTION_INDEX == indexPath.section && sortByStates.selectedRowIndex == indexPath.row)
  }
  
  func isSeeAllCategoryCell(indexPath: IndexPath) -> Bool {
    return isCategoryCollapsed(section: indexPath.section) && indexPath.row == 3
  }
  
  func getLabelByIndexPath(section: Int, row: Int) -> String {
    return (sections[section]["rowLabel"] as! [String])[row]
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isDistanceCollapsed(section: section) || isSortByCollapsed(section: section) {
      return 1
    } else if isCategoryCollapsed(section: section){
      return 4
    }
    return sections[section]["rowNum"] as! Int
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == DEAL_SECTION_INDEX {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath) as! DealCell
      cell.dealLabel.text = getLabelByIndexPath(section: indexPath.section, row: indexPath.row)
      
      cell.dealDelegate = self
      cell.dealSwitch.isOn = dealSwitchState
      return cell

    } else if isCheckBoxCell(section: indexPath.section) {
      
      if isDistanceCollapsed(section: indexPath.section) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        cell.label.text = distanceStates.selectedRowLabel
        return cell
        
      } else if isSortByCollapsed(section: indexPath.section) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
        cell.label.text = sortByStates.selectedRowLabel
        return cell
        
      } else {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckBoxCell", for: indexPath) as! CheckBoxCell
        cell.label.text = getLabelByIndexPath(section: indexPath.section, row: indexPath.row)
        cell.checkboxDelegate = self
        
        if isSelectedCheckBoxCell(indexPath: indexPath) {
          cell.button.setImage(checkedImage, for: UIControlState.normal)
        } else {
          cell.button.setImage(uncheckedImage, for: UIControlState.normal)
        }
        return cell

      }
    } else if indexPath.section == CATEGORY_SECTION_INDEX {
      if isCategoryExpanded || (!isCategoryExpanded && indexPath.row != 3) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategorySwitchCell", for: indexPath) as! CategorySwitchCell
        cell.switchLabel.text = categories[indexPath.row]["name"]
        cell.delegate = self
        cell.onSwitch.isOn = categorySwitchStates[indexPath.row] ?? false
        return cell
      } else {
        let cell = UITableViewCell()
        let seeAllLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        let seeAllLabelAttributes : [String: Any] = [
          NSForegroundColorAttributeName: UIColor.darkGray,
          NSFontAttributeName: UIFont(name: "Helvetica", size: 16.0)! ]
        seeAllLabel.attributedText = NSAttributedString( string: "See All" , attributes: seeAllLabelAttributes )
        seeAllLabel.textAlignment = .center
        
        cell.addSubview(seeAllLabel)
        return cell
      }

      
    } else {
      let cell = UITableViewCell()
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]["title"] as? String
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    headerView.backgroundColor = .white
    headerView.sizeToFit()
    
    let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.width-10, height: headerView.frame.height-18))
    let labelText = sections[section]["title"] as? String
    let labelAttributes : [String: Any] = [
      NSFontAttributeName: UIFont(name: "Helvetica-bold", size: 16.0)! ]
    label.attributedText = NSAttributedString( string: labelText!, attributes: labelAttributes )

    headerView.addSubview(label)

    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section != 0 {
      return 50
    } else {
      return 0
    }
    
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section == DISTANCE_SECTION_INDEX {
      isDistanceExpanded = !isDistanceExpanded
      tableView.reloadSections(IndexSet(indexPath), with: UITableViewRowAnimation.fade)
    } else if indexPath.section == SORT_BY_SECTION_INDEX {
      isSortByExpanded = !isSortByExpanded
      tableView.reloadSections(IndexSet(indexPath), with: UITableViewRowAnimation.fade)
    } else if isSeeAllCategoryCell(indexPath: indexPath) {
      isCategoryExpanded = !isCategoryExpanded
      tableView.reloadSections(IndexSet(indexPath), with: UITableViewRowAnimation.fade)
    }
  }
  
  
  func categorySwitchCell(categorySwitchCell: CategorySwitchCell, didChangeValue : Bool) {
    let indexPath = tableView.indexPath(for: categorySwitchCell)!
    categorySwitchStates[indexPath.row] = didChangeValue
  }
  
  func dealCell(dealCell: DealCell, didChangeValue: Bool) {
    dealSwitchState = didChangeValue
  }
  
  func checkboxCell(checkboxCell: CheckBoxCell, didChangeValue: Bool) {
    if didChangeValue {
      let indexPath = tableView.indexPath(for: checkboxCell)!
      let selectedRowLabel = getLabelByIndexPath(section: indexPath.section, row: indexPath.row)
      
      if indexPath.section == DISTANCE_SECTION_INDEX {
        distanceStates = (selectedRowIndex: indexPath.row, selectedRowLabel: selectedRowLabel)
        isDistanceExpanded = !isDistanceExpanded
      } else if indexPath.section == SORT_BY_SECTION_INDEX {
        sortByStates = (selectedRowIndex: indexPath.row, selectedRowLabel: selectedRowLabel)
        isSortByExpanded = !isSortByExpanded
      }

      tableView.reloadSections(IndexSet(indexPath), with: UITableViewRowAnimation.fade)
    }
  }
  
  func sectionData() -> [[String: Any]] {
    return [["title": "", "rowNum": 1, "rowLabel" : ["Offering a Deal"]],
            ["title": "Distance", "rowNum": 5, "rowLabel" : ["Auto","0.3 miles", "1 mile","5 mile","20 miles"]],
            ["title": "Sort By", "rowNum": 3, "rowLabel": ["Best Match","Distance","Rating"]],
            ["title": "Category", "rowNum": categories.count, "rowLabel":[]]]
  }
  
  func yelpCategories() -> [[String:String]] {
    return [["name" : "Afghan", "code": "afghani"],
                      ["name" : "African", "code": "african"],
                      ["name" : "American, New", "code": "newamerican"],
                      ["name" : "American, Traditional", "code": "tradamerican"],
                      ["name" : "Arabian", "code": "arabian"],
                      ["name" : "Argentine", "code": "argentine"],
                      ["name" : "Armenian", "code": "armenian"],
                      ["name" : "Asian Fusion", "code": "asianfusion"],
                      ["name" : "Asturian", "code": "asturian"],
                      ["name" : "Australian", "code": "australian"],
                      ["name" : "Austrian", "code": "austrian"],
                      ["name" : "Baguettes", "code": "baguettes"],
                      ["name" : "Bangladeshi", "code": "bangladeshi"],
                      ["name" : "Barbeque", "code": "bbq"],
                      ["name" : "Basque", "code": "basque"],
                      ["name" : "Bavarian", "code": "bavarian"],
                      ["name" : "Beer Garden", "code": "beergarden"],
                      ["name" : "Beer Hall", "code": "beerhall"],
                      ["name" : "Beisl", "code": "beisl"],
                      ["name" : "Belgian", "code": "belgian"],
                      ["name" : "Bistros", "code": "bistros"],
                      ["name" : "Black Sea", "code": "blacksea"],
                      ["name" : "Brasseries", "code": "brasseries"],
                      ["name" : "Brazilian", "code": "brazilian"],
                      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                      ["name" : "British", "code": "british"],
                      ["name" : "Buffets", "code": "buffets"],
                      ["name" : "Bulgarian", "code": "bulgarian"],
                      ["name" : "Burgers", "code": "burgers"],
                      ["name" : "Burmese", "code": "burmese"],
                      ["name" : "Cafes", "code": "cafes"],
                      ["name" : "Cafeteria", "code": "cafeteria"],
                      ["name" : "Cajun/Creole", "code": "cajun"],
                      ["name" : "Cambodian", "code": "cambodian"],
                      ["name" : "Canadian", "code": "New)"],
                      ["name" : "Canteen", "code": "canteen"],
                      ["name" : "Caribbean", "code": "caribbean"],
                      ["name" : "Catalan", "code": "catalan"],
                      ["name" : "Chech", "code": "chech"],
                      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                      ["name" : "Chicken Shop", "code": "chickenshop"],
                      ["name" : "Chicken Wings", "code": "chicken_wings"],
                      ["name" : "Chilean", "code": "chilean"],
                      ["name" : "Chinese", "code": "chinese"],
                      ["name" : "Comfort Food", "code": "comfortfood"],
                      ["name" : "Corsican", "code": "corsican"],
                      ["name" : "Creperies", "code": "creperies"],
                      ["name" : "Cuban", "code": "cuban"],
                      ["name" : "Curry Sausage", "code": "currysausage"],
                      ["name" : "Cypriot", "code": "cypriot"],
                      ["name" : "Czech", "code": "czech"],
                      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                      ["name" : "Danish", "code": "danish"],
                      ["name" : "Delis", "code": "delis"],
                      ["name" : "Diners", "code": "diners"],
                      ["name" : "Dumplings", "code": "dumplings"],
                      ["name" : "Eastern European", "code": "eastern_european"],
                      ["name" : "Ethiopian", "code": "ethiopian"],
                      ["name" : "Fast Food", "code": "hotdogs"],
                      ["name" : "Filipino", "code": "filipino"],
                      ["name" : "Fish & Chips", "code": "fishnchips"],
                      ["name" : "Fondue", "code": "fondue"],
                      ["name" : "Food Court", "code": "food_court"],
                      ["name" : "Food Stands", "code": "foodstands"],
                      ["name" : "French", "code": "french"],
                      ["name" : "French Southwest", "code": "sud_ouest"],
                      ["name" : "Galician", "code": "galician"],
                      ["name" : "Gastropubs", "code": "gastropubs"],
                      ["name" : "Georgian", "code": "georgian"],
                      ["name" : "German", "code": "german"],
                      ["name" : "Giblets", "code": "giblets"],
                      ["name" : "Gluten-Free", "code": "gluten_free"],
                      ["name" : "Greek", "code": "greek"],
                      ["name" : "Halal", "code": "halal"],
                      ["name" : "Hawaiian", "code": "hawaiian"],
                      ["name" : "Heuriger", "code": "heuriger"],
                      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                      ["name" : "Hot Dogs", "code": "hotdog"],
                      ["name" : "Hot Pot", "code": "hotpot"],
                      ["name" : "Hungarian", "code": "hungarian"],
                      ["name" : "Iberian", "code": "iberian"],
                      ["name" : "Indian", "code": "indpak"],
                      ["name" : "Indonesian", "code": "indonesian"],
                      ["name" : "International", "code": "international"],
                      ["name" : "Irish", "code": "irish"],
                      ["name" : "Island Pub", "code": "island_pub"],
                      ["name" : "Israeli", "code": "israeli"],
                      ["name" : "Italian", "code": "italian"],
                      ["name" : "Japanese", "code": "japanese"],
                      ["name" : "Jewish", "code": "jewish"],
                      ["name" : "Kebab", "code": "kebab"],
                      ["name" : "Korean", "code": "korean"],
                      ["name" : "Kosher", "code": "kosher"],
                      ["name" : "Kurdish", "code": "kurdish"],
                      ["name" : "Laos", "code": "laos"],
                      ["name" : "Laotian", "code": "laotian"],
                      ["name" : "Latin American", "code": "latin"],
                      ["name" : "Live/Raw Food", "code": "raw_food"],
                      ["name" : "Lyonnais", "code": "lyonnais"],
                      ["name" : "Malaysian", "code": "malaysian"],
                      ["name" : "Meatballs", "code": "meatballs"],
                      ["name" : "Mediterranean", "code": "mediterranean"],
                      ["name" : "Mexican", "code": "mexican"],
                      ["name" : "Middle Eastern", "code": "mideastern"],
                      ["name" : "Milk Bars", "code": "milkbars"],
                      ["name" : "Modern Australian", "code": "modern_australian"],
                      ["name" : "Modern European", "code": "modern_european"],
                      ["name" : "Mongolian", "code": "mongolian"],
                      ["name" : "Moroccan", "code": "moroccan"],
                      ["name" : "New Zealand", "code": "newzealand"],
                      ["name" : "Night Food", "code": "nightfood"],
                      ["name" : "Norcinerie", "code": "norcinerie"],
                      ["name" : "Open Sandwiches", "code": "opensandwiches"],
                      ["name" : "Oriental", "code": "oriental"],
                      ["name" : "Pakistani", "code": "pakistani"],
                      ["name" : "Parent Cafes", "code": "eltern_cafes"],
                      ["name" : "Parma", "code": "parma"],
                      ["name" : "Persian/Iranian", "code": "persian"],
                      ["name" : "Peruvian", "code": "peruvian"],
                      ["name" : "Pita", "code": "pita"],
                      ["name" : "Pizza", "code": "pizza"],
                      ["name" : "Polish", "code": "polish"],
                      ["name" : "Portuguese", "code": "portuguese"],
                      ["name" : "Potatoes", "code": "potatoes"],
                      ["name" : "Poutineries", "code": "poutineries"],
                      ["name" : "Pub Food", "code": "pubfood"],
                      ["name" : "Rice", "code": "riceshop"],
                      ["name" : "Romanian", "code": "romanian"],
                      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                      ["name" : "Rumanian", "code": "rumanian"],
                      ["name" : "Russian", "code": "russian"],
                      ["name" : "Salad", "code": "salad"],
                      ["name" : "Sandwiches", "code": "sandwiches"],
                      ["name" : "Scandinavian", "code": "scandinavian"],
                      ["name" : "Scottish", "code": "scottish"],
                      ["name" : "Seafood", "code": "seafood"],
                      ["name" : "Serbo Croatian", "code": "serbocroatian"],
                      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                      ["name" : "Singaporean", "code": "singaporean"],
                      ["name" : "Slovakian", "code": "slovakian"],
                      ["name" : "Soul Food", "code": "soulfood"],
                      ["name" : "Soup", "code": "soup"],
                      ["name" : "Southern", "code": "southern"],
                      ["name" : "Spanish", "code": "spanish"],
                      ["name" : "Steakhouses", "code": "steak"],
                      ["name" : "Sushi Bars", "code": "sushi"],
                      ["name" : "Swabian", "code": "swabian"],
                      ["name" : "Swedish", "code": "swedish"],
                      ["name" : "Swiss Food", "code": "swissfood"],
                      ["name" : "Tabernas", "code": "tabernas"],
                      ["name" : "Taiwanese", "code": "taiwanese"],
                      ["name" : "Tapas Bars", "code": "tapas"],
                      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                      ["name" : "Tex-Mex", "code": "tex-mex"],
                      ["name" : "Thai", "code": "thai"],
                      ["name" : "Traditional Norwegian", "code": "norwegian"],
                      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                      ["name" : "Trattorie", "code": "trattorie"],
                      ["name" : "Turkish", "code": "turkish"],
                      ["name" : "Ukrainian", "code": "ukrainian"],
                      ["name" : "Uzbek", "code": "uzbek"],
                      ["name" : "Vegan", "code": "vegan"],
                      ["name" : "Vegetarian", "code": "vegetarian"],
                      ["name" : "Venison", "code": "venison"],
                      ["name" : "Vietnamese", "code": "vietnamese"],
                      ["name" : "Wok", "code": "wok"],
                      ["name" : "Wraps", "code": "wraps"],
                      ["name" : "Yugoslav", "code": "yugoslav"]]
  }
  
  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */

}
