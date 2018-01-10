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

class SearchTableViewController: UITableViewController {
    
    // All places fetched from Core Data
    var places: [Place] = []
    // Places matching the search, at beginning containing also all places
    var filteredPlaces: [Place] = []
    // Can be used to transfer search data to map VC
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    override func viewDidLoad() {
        
        // Do ONCE to get it into Core Data for testing, otherwise you get duplicates
//        self.save(name: "Mensa", latitude: 50.7795, longitude: 6.0595)
//        self.save(name: "Aula 2", latitude: 50.7794, longitude: 6.0585)
//        self.save(name: "Fachschaft", latitude: 50.7790, longitude: 6.0591)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Fetch data from storage into places array to use it for search
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")

        do {
            places = try managedContext.fetch(fetchRequest) as! [Place]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        filteredPlaces = places
    }

    // Used to enter data into persistent storage
    func save(name: String, latitude: Double, longitude: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext)!
        
        let place = NSManagedObject(entity: entity, insertInto: managedContext)

        place.setValue(name, forKeyPath: "name")
        place.setValue(latitude, forKey: "latitude")
        place.setValue(longitude, forKey: "longitude")

        do {
            try managedContext.save()
            places.append(place as! Place)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Search for appearance of entered string in any place name
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlaces = places.filter({( place : Place) -> Bool in
            return (place.name?.lowercased().contains(searchText.lowercased()))!
        })
        // Reset filter if no text is entered to show all places
        if (searchText == "") {
            filteredPlaces = places
        }
        tableView.reloadData()
    }
}

// Includes all searchResult delegates
extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Used to display all places when search bar is tapped but no text is entered yet
        searchController.searchResultsController?.view.isHidden = false
        // Adapt tableView content based on updated search input
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


// Includes all tableView delegates
extension SearchTableViewController {
    
    // Filter according to search input
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    // At default display all places
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let place = filteredPlaces[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = place.value(forKeyPath: "name") as? String
            return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredPlaces[indexPath.row]
        handleMapSearchDelegate?.placePin(location: selectedItem)
        dismiss(animated: true, completion: nil)
    }
    
}
