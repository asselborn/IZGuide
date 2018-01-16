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
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var resultSearchController: UISearchController? = nil
    
    let mapOverlay = MapOverlay(imageName: "OverlayBase")
    
    let locationManager = CLLocationManager()
    var localPosition: CLLocationCoordinate2D?
    
    @IBOutlet weak var startNavigationButton: UIButton!
    
    @IBOutlet weak var plusLevelButton: UIButton!
    
    @IBOutlet weak var minusLevelButton: UIButton!
    
    @IBOutlet weak var levelTextfield: UITextField!
    
    // saves the user level
    var userLevel: Int = 0
    
    // Reference to map
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set map type
        self.mapView.mapType = MKMapType.mutedStandard

        // Set VC as delegate to handle custom rendering
        self.mapView.delegate = self
        
        // Center map on Informatikzentrum
        let position = CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0592)
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
        
        
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchTableViewController") as! SearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.handleMapSearchDelegate = self
        
        startScanning()
        
        // hide startNavigation button
        startNavigationButton.isHidden = true
        
        // round corners of buttons
        startNavigationButton.layer.cornerRadius = 6
        plusLevelButton.layer.cornerRadius = 6
        minusLevelButton.layer.cornerRadius = 6
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
        
        startNavigationButton.isHidden = true
        
        // TODO
        // start the navigation using the predefined tree
        
    }
    
    @IBAction func plusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel + 1
        
        // check that maximum level is 3
        if userLevel > 3 { userLevel = 3 }
        levelTextfield.text = String(userLevel)
        
        // TODO
        // change building overlay to the next level
    }
    
    @IBAction func minusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel - 1
        
        // check that minimum level is -1
        if userLevel < -1 { userLevel = -1 }
        levelTextfield.text = String(userLevel)
        
        // TODO
        // change building overlay to the previous level
    }
    
    
}



// Extension containing used MKMapViewDelegate functions
extension MapViewController: MKMapViewDelegate {
    
    // Gets called when overlay is in view and needs to be rendered
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapOverlay = overlay as? MapOverlay, let image = UIImage(named: mapOverlay.imageName) {
            return MapOverlayView(overlay: overlay, overlayImage: image)
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
}

extension MapViewController: HandleMapSearch {
    func placePin(location: Place) {
        // Enter full text of selection into search textfield
        resultSearchController?.searchBar.text = location.name
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = location.name
        mapView.addAnnotation(annotation)
        
        // show the navigation button
        startNavigationButton.isHidden = false
    }
}
