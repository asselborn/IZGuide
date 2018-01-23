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
    
    // All places fetched from Core Data
    var places: [Place] = []
    
    // Places matching the search, at beginning containing also all places
    var filteredPlaces: [Place] = []
    
    // Can be used to transfer search data to map VC
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    override func viewDidLoad() {
        self.load()
        
        // Sample data for testing
        self.save(name: "Aula 2",
                  latitude: 50.779346565464131,
                  longitude: 6.058560755739216,
                  category: "Room",
                  floor: 0,
                  url: "https://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2352%7C021&expand=Campus+H%F6rn&building=Aula+und+Mensa&tguid=0x0C459501268AC043A64ED1E2F7FA6BEF",
                  building: "Hauptbau_1")
        self.save(name: "AH 4",
                  latitude: 50.779557255663697,
                  longitude: 6.059148695737858,
                  category: "Room",
                  floor: 0,
                  url: "https://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2354%7C030&expand=Campus+H%F6rn&building=H%F6rsaal+an+der+Mensa&tguid=0x0C459501268AC043A64ED1E2F7FA6BEF",
                  building: "Hauptbau_1")
        self.save(name: "Mensa Ahornstr.",
                  latitude: 50.779549951572719,
                  longitude: 6.059539136996885,
                  category: "Room",
                  floor: 0,
                  url: "http://www.studierendenwerk-aachen.de/de/Gastronomie/mensa-ahornstrasse-wochenplan.html",
                  building: "Hauptbau_1")
        self.save(name: "Informatik 10 - Media Computing Group",
                  latitude: 50.779021862771607,
                  longitude: 6.0591637127093829,
                  category: "Chair",
                  floor: 2,
                  url: "http://hci.rwth-aachen.de",
                  building: "Hauptbau_2")
        self.save(name: "Prof. Dr. Jan Borchers",
                  latitude: 50.779021862771607,
                  longitude: 6.0591637127093829,
                  category: "Person",
                  floor: 2,
                  url: "http://hci.rwth-aachen.de/borchers",
                  building: "Hauptbau_2")
        self.save(name: "Computer Science Library",
                  latitude: 50.778527255204068,
                  longitude: 6.0599260221284084,
                  category: "Room",
                  floor: 0,
                  url: "http://tcs.rwth-aachen.de/www-bib/index.php",
                  building: "E1")
        self.save(name: "Sporthallenkomplex Ahornstr.",
                  latitude: 50.778521512278203,
                  longitude: 6.0592188711139707,
                  category: "Room",
                  floor: 0,
                  url: "http://hochschulsport.rwth-aachen.de/",
                  building: "Hauptbau_2")
        self.save(name: "InfoSphere - Schülerlabor Informatik",
                  latitude: 50.779014572047124,
                  longitude: 6.060270794456585,
                  category: "Room",
                  floor: -1,
                  url: "http://schuelerlabor.informatik.rwth-aachen.de/",
                  building: "E3")
        self.save(name: "Informatik 11 - Embedded Software",
                  latitude: 50.778985027020873,
                  longitude: 6.0591560493499452,
                  category: "Chair",
                  floor: 3,
                  url: "https://embedded.rwth-aachen.de/",
                  building: "Hauptbau_2")
        self.save(name: "Prof. Dr.-Ing. Stefan Kowalewski",
                  latitude: 50.778985027020873,
                  longitude: 6.0591560493499452,
                  category: "Person",
                  floor: 3,
                  url: "https://embedded.rwth-aachen.de/doku.php?id=lehrstuhl:mitarbeiter:kowalewski",
                  building: "Hauptbau_2")
        self.save(name: "Knowledge-Based Systems Group",
                  latitude: 50.778276368134215,
                  longitude: 6.0609121860457291,
                  category: "Chair",
                  floor: 2,
                  url: "https://kbsg.rwth-aachen.de/",   
                  building: "E2")   
        self.save(name: "Prof. Gerhard Lakemeyer, Ph.D.",
                  latitude: 50.778276368134215,
                  longitude: 6.0609121860457291,
                  category: "Person",
                  floor: 2,
                  url: "https://kbsg.rwth-aachen.de/user/7",   
                  building: "E2")  
        
    }
    
    // Reset map for new search
    override func viewDidAppear(_ animated: Bool) {
        handleMapSearchDelegate?.reset()
    }
    
    // Fetch data from storage into places array to use it for search
    func load() {
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
    func save(name: String, latitude: Double, longitude: Double, category: String, floor: Int16, url: String?, building: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        // Check first to avoid duplicates
        for place in places {
            if (place.name == name) {
                return
            }
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext)!
        let place = NSManagedObject(entity: entity, insertInto: managedContext)

        place.setValue(name, forKeyPath: "name")
        place.setValue(latitude, forKey: "latitude")
        place.setValue(longitude, forKey: "longitude")
        place.setValue(category, forKey: "category")
        place.setValue(floor, forKey: "floor")
        place.setValue(url, forKey: "url")
        place.setValue(building, forKey: "building")

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
            let categoryCheck = (scope == "All" || place.category == scope)
            if (searchText == "") {
                return categoryCheck
            }
            else {
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
