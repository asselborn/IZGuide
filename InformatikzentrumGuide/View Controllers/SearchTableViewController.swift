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
    
    var places: [NSManagedObject] = []
    
    override func viewDidLoad() {
        
        // Do ONCE to get it into Core Data for testing, else you get duplicates
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
            places = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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
            places.append(place)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Used to display all places when search bar is tapped but no text is entered yet
        searchController.searchResultsController?.view.isHidden = false
    }
}

extension SearchTableViewController {
    
    // Filter according to search input
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    // At default display all places
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let place = places[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = place.value(forKeyPath: "name") as? String
            return cell
    }
}
