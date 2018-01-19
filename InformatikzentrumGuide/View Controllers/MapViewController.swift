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
    func reset()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // Define marker areas for buildings and stairs
    var e1Marker: MKPolygon?
    // TODO
    var e2Marker: MKPolygon?
    var e3Marker: MKPolygon?
    var hauptbauMarker: MKPolygon?
    var stairsHauptbau_1: MKPolygon?
    var stairsHauptbau_2: MKPolygon?
    var stairsE1: MKPolygon?
    var stairsE2: MKPolygon?
    var stairsE3: MKPolygon?
    
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
    
    // Unnecessary to hand over image, since image is declared below
    let mapOverlay = MapOverlay()
    
    var searchResult: UISearchController? = nil
    var searchVC: SearchResultsViewController? = nil
    
    // The images for the map overlay
    let groundfloorImage: UIImage = IZGroundfloor.imageOfCanvas1
    let basementImage: UIImage = IZBasement.imageOfCanvas1
    let firstFloorImage: UIImage = IZFirstFloor.imageOfCanvas1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = true
        
        // Set map type
        self.mapView.mapType = MKMapType.mutedStandard
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
        
        // Set markers
        var vertices = Array<CLLocationCoordinate2D>()
        vertices.append(CLLocationCoordinate2D(latitude: 50.778856766109392, longitude: 6.0599851211412172))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778538833045197, longitude: 6.0601530394202516))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778513038381043, longitude: 6.0600496321184956))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77831927800711, longitude: 6.0601463985844122))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778295282858508, longitude: 6.0600249661566608))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778278486247125, longitude: 6.0600429912826561))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778256290715724, longitude: 6.059967096015324))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77860421945573, longitude: 6.0597821013011579))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778622215699464, longitude: 6.0598779190762118))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778788980561892, longitude: 6.0597953829728368))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778810575968222, longitude: 6.0599111232556124))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778838170084008, longitude: 6.0598987902745929))
        e1Marker = MKPolygon(coordinates: vertices, count: 12)
        

        // Show user location
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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 72/255, green: 200/255, blue: 73/255, alpha: 1),
                                                                   NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 26)!]
        
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
    }
    
    // Prints tapped location in helpful format to quickly get location information to setup markers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let position = touches.first?.preciseLocation(in: self.mapView)
        print("vertices.append(\(self.mapView.convert(position!, toCoordinateFrom: self.mapView)))")
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "C2A94B61-726C-4954-3230-313478303031")
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "Test")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    // Gets called when registered beacons are in range
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let beacon = beacons[0]
            update(distance: beacon.proximity)
        }
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
    
    @IBAction func startNavigationButtonPressed(_ sender: UIButton) {
        startNavigationButton.isEnabled = false
        self.adjustGuidance()
    }
    
    // Should be called whenever a defined location area is entered (one for Hauptbau, E1, E2, E3) or the userLevel is changed
    func adjustGuidance() {
        
        // TODO
        // STRUCTURE
        // Check if yor are at correct building
            // If yes check if you are at correct floor
                // If yes just show pin
                // If no highlight next stairs
            // If not check if you are on groundfloor
                // If yes highlight correct building
                // If not highlight next stairs
        
        // Test
        if let destination = self.currentPlace {
            
            // TODO: Check if yor are at correct building
            if (false) {
                // Check if you are at correct floor
                if (userLevel == destination.floor) {
                    let text = NSMutableAttributedString(string: "Go to Pin")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                }
                else {
                    let text = NSMutableAttributedString(string: "Go to Stairs")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                }
            }
            
            // Not at correct building
            else {
                // Check if you are at groundfloor to change buildings
                if (userLevel == 0) {
                    let text = NSMutableAttributedString(string: "Go to \((destination.building)!) Building")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                }
                else {
                    let text = NSMutableAttributedString(string: "Go to Stairs")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                }
            }
        }
    }
    
    
    @IBAction func plusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel + 1
        
        // check that maximum level is 3
        if userLevel > 3 { userLevel = 3 }
        levelLabel.text = String(userLevel)
        
        self.adjustAnnotations()
        self.adjustGuidance()
        
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
        self.adjustGuidance()
        
        // change building overlay to the previous level
        mapView.removeOverlays(mapView.overlays)
        mapView.add(mapOverlay)
    }
    
    // Reset annotation images to adapt to current floor
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
    
    // If available open URL connected to current place
    @objc func infoButtonPressed() {
        guard let urlString = self.currentPlace?.url, let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
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
                return MapOverlayView(overlay: mapOverlay, overlayImage: firstFloorImage)
            case 2:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            case 3:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            default:
                return MapOverlayView(overlay: mapOverlay, overlayImage: groundfloorImage)
            }
        }
            
        // Define properties of guidance markers
        else if let marker = overlay as? MKPolygon {
            let markerView = MKPolygonRenderer(polygon: marker)
            markerView.lineWidth = 0
            markerView.fillColor = green
            markerView.alpha = 0.5
            return markerView
        }
        
        return MKOverlayRenderer()
    }
    
    // Gets called when annotation is in view and needs to be displayed
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        // Ignore user location
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.canShowCallout = true
        
        // Set image based on relative position to floor of location
        if (userLevel == currentPlace?.floor) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star")
        }
        else if (userLevel < (currentPlace?.floor)!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Up")
        }
        else if (userLevel > (currentPlace?.floor)!) {
            annotationView?.image = #imageLiteral(resourceName: "Pin_Star_Down")
        }
        
        // Add an info button if URL is available
        if (self.currentPlace?.url) != nil {
            let infoButton = UIButton(type: .infoLight)
            infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
            annotationView?.rightCalloutAccessoryView = infoButton
        }
        
        // Shift image position, at default location would be in center of custom image
        annotationView?.centerOffset = CGPoint(x: 0, y: -(annotationView?.frame.size.height)! / 2)
        
        return annotationView
    }
}


// Handle communication coming from SearchResultsVC
extension MapViewController: HandleMapSearch {
    
    // Place a pin for the selected Place
    func placePin(location: Place) {
        
        // Set current location
        self.currentPlace = location
        
        // Enter full text of selection into search textfield
        searchResult?.searchBar.text = location.name
        
        // Add annotation
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = location.name
        let floor = location.floor
        annotation.subtitle = "Floor: \(floor)"
        mapView.addAnnotation(annotation)
        
        // Show the navigation button to offer guidance
        navigationController?.isToolbarHidden = false
    }

    // Remove annotation pin and any marker overlay. Enable "Guide Me" button again, toolbar is hidden till a new pin is placed.
    func reset() {
        
        // Reset location
        self.currentPlace = nil
        mapView.removeAnnotations(mapView.annotations)
        
        // Reset overlays
        self.mapView.removeOverlays(mapView.overlays)
        self.mapView.add(mapOverlay)
        
        // Reset toolbar
        startNavigationButton.isEnabled = true
        startNavigationButton.setTitle("Guide Me", for: .normal)
        navigationController?.isToolbarHidden = true
    }
}

