//
//  SearchViewController.swift
//  InformatikzentrumGuide
//
//  Created by David Asselborn on 10.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchResultsViewController: UITableViewController {
    
    // Places matching the search, at beginning containing all places
    var filteredPlaces: [Place] = []
    
    // Can be used to transfer search data to map VC
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    // Helper function waiting until data is fetched/crawled
    func waitForPlaces() -> [Place] {
        if handleMapSearchDelegate != nil {
            return handleMapSearchDelegate!.waitForPlaces()
        }
        else {
            return []
        }
    }
    
    override func viewDidLoad() {
        filteredPlaces = waitForPlaces()
    }
    
    // Reset map for new search
    override func viewDidAppear(_ animated: Bool) {
        handleMapSearchDelegate?.reset()
    }
    
    // Search for appearance of entered string in any place name
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlaces = waitForPlaces().filter({( place : Place) -> Bool in
            // Filter categories based on scope
            let categoryCheck = (scope == "All" || place.category == scope)
            if (searchText == "") {
                return categoryCheck
            }
            else {
                // If any search text is entered, additionally filter according to that
                return categoryCheck && (place.name?.lowercased().contains(searchText.lowercased()))!
            }
        })
        tableView.reloadData()
    }
}

// Includes all searchResult delegates
extension SearchResultsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    // Gets called when search field is edited
    func updateSearchResults(for searchController: UISearchController) {
        // Used to display all places when search bar is tapped but no text is entered yet
        searchController.searchResultsController?.view.isHidden = false
        // Adapt tableView content based on updated search input
        let scope = searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    // Gets called when search scope is edited
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

// Includes all tableView delegates
extension SearchResultsViewController {
    
    // Set table length according to filtered search input
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    // Display all filtered places
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let place = filteredPlaces[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = place.value(forKeyPath: "name") as? String
            return cell
    }
    
    // Get called when row is selected, place pin on map
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredPlaces[indexPath.row]
        handleMapSearchDelegate?.placePin(location: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
