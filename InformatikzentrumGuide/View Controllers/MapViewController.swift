//
//  MapViewController.swift
//  InformatikzentrumGuide
//
//  Created by David Asselborn on 02.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func placePin(location: Place)
    func clearAnnotations()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // Define stylish green color used throughout the app, can of course be changed
    let green = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    
    @IBOutlet weak var startNavigationButton: UIButton!
    @IBOutlet weak var plusLevelButton: UIButton!
    @IBOutlet weak var minusLevelButton: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    
    // Saves the user level
    var userLevel: Int16 = 0
    
    // Reference to map
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var localPosition: CLLocationCoordinate2D?
    
    // Unnecessary to hand over image, since image is declared belor
    let mapOverlay = MapOverlay()

    var searchResult: UISearchController? = nil
    var searchVC: SearchResultsViewController? = nil
    
    // The image for the map overlay
    let imageForOverlay: UIImage = IZGroundfloor.imageOfCanvas1

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = true
        
        // Set map type
        self.mapView.mapType = MKMapType.mutedStandard

        // Set VC as delegate to handle custom rendering
        self.mapView.delegate = self
        
        // Center map on Informatikzentrum
        let position = CLLocationCoordinate2D(latitude: 50.77884046, longitude: 6.05975926)
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let region = MKCoordinateRegionMake(position, span)
        mapView.region = region

        // Init overlay for indoor map, base floor
        self.mapView.add(mapOverlay)
        
//        // Test marker overlay for later navigation
//        var vertices = Array<CLLocationCoordinate2D>()
//        vertices.append(CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0592))
//        vertices.append(CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0594))
//        vertices.append(CLLocationCoordinate2D(latitude: 50.779, longitude: 6.0594))
//        vertices.append(CLLocationCoordinate2D(latitude: 50.779, longitude: 6.0592))
//        let marker = MKPolygon(coordinates: vertices, count: 4)
//        self.mapView.add(marker)
        
        // Show user location (Set at Ahornstr. entrance in simulator)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            localPosition = locationManager.location?.coordinate
        }
        mapView.showsUserLocation = true
        
        navigationItem.title = "IZGuide"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: green, NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 20)!]
        
        // Init new view controller to handle display of search results
        searchVC = storyboard!.instantiateViewController(withIdentifier: "SearchResultsViewController") as? SearchResultsViewController
        // Init new search controller to handle calculation of search results
        searchResult = UISearchController(searchResultsController: searchVC)
        searchResult?.searchBar.tintColor = green
        searchResult?.searchResultsUpdater = searchVC
        searchResult?.searchBar.placeholder = "Search for places"
        navigationItem.searchController = searchResult
        definesPresentationContext = true
        
        // Init scope bar
        searchResult?.searchBar.scopeButtonTitles = ["All", "Room", "Chair", "Person"]
        searchResult?.searchBar.delegate = searchVC
        
        // Setup connection between the two VC to exchange information to set pin
        searchVC?.handleMapSearchDelegate = self
        
        startScanning()

        // round corners of buttons
        startNavigationButton.layer.cornerRadius = 9
        plusLevelButton.layer.cornerRadius = 9
        minusLevelButton.layer.cornerRadius = 9
        
        levelLabel.layer.borderWidth = 1
        
        // Add navigation button to toolbar
        self.toolbarItems = [UIBarButtonItem(customView: startNavigationButton)]
        
        createTree()
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "C2A94B61-726C-4954-3230-313478303031")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Test")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func update(distance: CLProximity) {
        switch distance {
        case .unknown:
            print("Unknown")
            
        case .far:
            print("Far")
            
        case .near:
            print("Near")
            
        case .immediate:
            print("Right Here")
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            update(distance: beacon.proximity)
        }
    }
    
    @IBAction func startNavigationButtonPressed(_ sender: UIButton) {
        
        // TODO
        // start the navigation using the predefined tree
        
    }
    
    @IBAction func plusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel + 1
        
        // check that maximum level is 3
        if userLevel > 3 { userLevel = 3 }
        levelLabel.text = String(userLevel)
        self.adjustAnnotations()
        // TODO
        // change building overlay to the next level
    }
    
    @IBAction func minusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel - 1
        
        // check that minimum level is -1
        if userLevel < -1 { userLevel = -1 }
        levelLabel.text = String(userLevel)
        self.adjustAnnotations()
        
        // TODO
        // change building overlay to the previous level
    }
    
    // Reset annotation images depending to adapt to current floor
    func adjustAnnotations() {
        for annotation in self.mapView.annotations {
            let annotationView = self.mapView.view(for: annotation)
            if (userLevel == self.searchVC?.getFloor(name: (annotation.title)!!)) {
                annotationView?.image = #imageLiteral(resourceName: "Pin_Star")
            }
            else if (userLevel < (self.searchVC?.getFloor(name: (annotation.title)!!))!) {
                annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Up")
            }
            else if (userLevel > (self.searchVC?.getFloor(name: (annotation.title)!!))!) {
                annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Down")
            }
        }
    }
    
}


// Extension containing used MKMapViewDelegate functions
extension MapViewController: MKMapViewDelegate {
    // Gets called when overlay is in view and needs to be rendered
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapOverlay = overlay as? MapOverlay {
            return MapOverlayView(overlay: mapOverlay, overlayImage: imageForOverlay)
        }
        
        else if let marker = overlay as? MKPolygon {
            let markerView = MKPolygonRenderer(polygon: marker)
            markerView.lineWidth = 0
            markerView.fillColor = UIColor.green
            markerView.alpha = 0.3
            return markerView
        }
        return MKOverlayRenderer()
    }
    
     // Gets called when annotation is in view and needs to be displayed
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        if (userLevel == self.searchVC?.getFloor(name: (annotation.title)!!)) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star")
        }
        else if (userLevel < (self.searchVC?.getFloor(name: (annotation.title)!!))!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Up")
        }
        else if (userLevel > (self.searchVC?.getFloor(name: (annotation.title)!!))!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Down")
        }
        // Set pin position at location, at default it would be in center of custom image
        annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.frame.size.height)! / 2)
        return annotationView
    }
}



extension MapViewController: HandleMapSearch {
    func placePin(location: Place) {
        // Enter full text of selection into search textfield
        searchResult?.searchBar.text = location.name
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = location.name
        let floor = location.floor
        annotation.subtitle = "Floor: \(floor)"
        mapView.addAnnotation(annotation)
        
        // show the navigation button
        navigationController?.isToolbarHidden = false
    }
    
    func clearAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        navigationController?.isToolbarHidden = true
    }
}
