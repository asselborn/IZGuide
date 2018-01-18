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
    func disableToolbar()
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
    
    // Saves the currently chosen place
    var currentPlace: Place?
    
    // Reference to map
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var localPosition: CLLocationCoordinate2D?
    
    // Unnecessary to hand over image, since image is declared belor
    let mapOverlay = MapOverlay()
    
    var searchResult: UISearchController? = nil
    var searchVC: SearchResultsViewController? = nil
    
    // The images for the map overlay
    let groundfloorImage: UIImage = IZGroundfloor.imageOfCanvas1
    let basementImage: UIImage = IZBasement.imageOfCanvas1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = true
        
        // Set map type
        self.mapView.mapType = MKMapType.satellite
        self.mapView.showsPointsOfInterest = false
        self.mapView.tintColor = green
        
        // Set VC as delegate to handle custom rendering
        self.mapView.delegate = self
        
        // Center map on Informatikzentrum
        let position = CLLocationCoordinate2D(latitude: 50.77884, longitude: 6.05975)
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 72/255, green: 200/255, blue: 73/255, alpha: 1), NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 26)!]
        
        
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
        plusLevelButton.layer.borderWidth = 1
        minusLevelButton.layer.cornerRadius = 9
        minusLevelButton.layer.borderWidth = 1
        
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
        
        // change building overlay to the previous level
        mapView.removeOverlays(mapView.overlays)
        mapView.add(mapOverlay)
    }
    
    @IBAction func minusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel - 1
        
        // check that minimum level is -1
        if userLevel < -1 { userLevel = -1 }
        levelLabel.text = String(userLevel)
        self.adjustAnnotations()
        
        // change building overlay to the previous level
        mapView.removeOverlays(mapView.overlays)
        mapView.add(mapOverlay)
    }
    
    // Reset annotation images depending to adapt to current floor
    func adjustAnnotations() {
        for annotation in self.mapView.annotations {
            if (annotation is MKPointAnnotation) {
                let annotationView = self.mapView.view(for: annotation)
                if (userLevel == currentPlace?.floor) {
                    annotationView?.image = #imageLiteral(resourceName: "Pin_Star")
                }
                else if (userLevel < (currentPlace?.floor)!) {
                    annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Up")
                }
                else if (userLevel > (currentPlace?.floor)!) {
                    annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Down")
                }
            }
        }
    }
    
}


// Extension containing used MKMapViewDelegate functions
extension MapViewController: MKMapViewDelegate {
    // Gets called when overlay is in view and needs to be rendered
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapOverlay = overlay as? MapOverlay {
            // Select the overlay image dependent on current floor
            switch(userLevel) {
            case -1:
                return MapOverlayView(overlay: mapOverlay, overlayImage: basementImage)
            case 0:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            case 1:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            case 2:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            case 3:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            default:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            }
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
        if (userLevel == currentPlace?.floor) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star")
        }
        else if (userLevel < (currentPlace?.floor)!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Up")
        }
        else if (userLevel > (currentPlace?.floor)!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Down")
        }
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        annotationView?.rightCalloutAccessoryView = infoButton
        // Set pin position at location, at default it would be in center of custom image
        annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.frame.size.height)! / 2)
        return annotationView
    }
    @objc func infoButtonPressed() {
        UIApplication.shared.open(URL(string: (self.currentPlace?.url)!)!)
    }
}



extension MapViewController: HandleMapSearch {
    func placePin(location: Place) {
        self.currentPlace = location
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
        self.currentPlace = nil
        mapView.removeAnnotations(mapView.annotations)
        navigationController?.isToolbarHidden = true
    }
    
    func disableToolbar() {
        navigationController?.isToolbarHidden = true
    }
}

