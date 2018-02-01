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

// Maybe use to replace String
enum BuildingPart {
    case Hauptbau
    case E1
    case E2
    case E3
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    // Contains different locations for the beacons
    var beaconLocationBuilding = [NSNumber:String]()
    var beaconLocationFloor = [NSNumber:Int16]()
    
    // Define marker areas for buildings and stairs
    var e1Marker: MKPolygon?
    var e2Marker: MKPolygon?
    var e3Marker: MKPolygon?
    var hauptbau_1_Marker: MKPolygon?
    var hauptbau_2_Marker: MKPolygon?
    var hauptbauMarker: MKPolygon?
    var hauptbauMarkerAdjusted: MKPolygon?
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
    let groundfloorImage: UIImage = IZGroundFloor.imageOfCanvas1
    let basementImage: UIImage = IZBasement.imageOfCanvas1
    let firstFloorImage: UIImage = IZFirstFloor.imageOfCanvas1
    let secondFloorImage: UIImage = IZSecondFloor.imageOfCanvas1
    let thirdFloorImage: UIImage = IZThirdFloor.imageOfCanvas1
    
    
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
        let span = MKCoordinateSpanMake(0.0026, 0.0026)
        let region = MKCoordinateRegionMake(position, span)
        mapView.region = region
        
        // Init overlay for indoor map, base floor
        self.mapView.add(mapOverlay)
        
        // Setup beacons

        beaconLocationFloor[6] = 0
        beaconLocationBuilding[6] = "Outside"
        
        beaconLocationFloor[13] = 0
        beaconLocationBuilding[13] = "Hauptbau"
        
        beaconLocationFloor[14] = 1
        beaconLocationBuilding[14] = "Hauptbau"
        
        beaconLocationFloor[24] = 2
        beaconLocationBuilding[24] = "Hauptbau"
        
        beaconLocationFloor[25] = 2
        beaconLocationBuilding[25] = "Destination"

    
        // Loads the overlays for each part of the buidling (Hauptbau, E1, E2, ...) and stairs
        loadOverlaysForBuildingParts()
        
        // Add a button to reset to user location and change tracking modes
        let userTrackingButton = MKUserTrackingButton(mapView: self.mapView)
        userTrackingButton.layer.backgroundColor = UIColor(white: 1, alpha: 0.7).cgColor
        userTrackingButton.layer.cornerRadius = 5
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.addSubview(userTrackingButton)
        
        // Position it below the default compass
        NSLayoutConstraint.activate([userTrackingButton.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 45),
                                     userTrackingButton.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -4),
                                     ])
        
        self.mapView.isPitchEnabled = false

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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: green,
                                                                   NSAttributedStringKey.font: UIFont(name: "Helvetica Neue",                                                                                                                                                                                                       size: 26)!]
        
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
        
        // Round corners of buttons
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
        if let nearestBeacon = beacons.first {
            // If a registered beacon is close, update the overlays using the associated informations
            if (nearestBeacon.proximity == .near || nearestBeacon.proximity == .immediate || nearestBeacon.proximity == .far) {
                if let floor = self.beaconLocationFloor[nearestBeacon.minor], let building = self.beaconLocationBuilding[nearestBeacon.minor] {
                    // Only update if navigation has started
                    if (startNavigationButton.isEnabled == false) {
                        print("Beacon says I am at floor \(floor) in building \(building)")
                        self.adjustGuidance(building: building, floor: floor)
                    }
                }
            }
        }
    }
    
    @IBAction func startNavigationButtonPressed(_ sender: UIButton) {
        startNavigationButton.isEnabled = false
        self.adjustGuidance(building: nil, floor: nil)
    }
    
    // Should be called whenever a defined location area is entered (one for Hauptbau_1, Hauptbau_2 E1, E2, E3) or the userLevel is changed
    // New optional parameters, only used to insert beacon information into the original structure
    func adjustGuidance(building: String?, floor: Int16?) {

        
        // Automatically switch floor, when matching beacon is detected
        if let floorInformation = floor {
            self.userLevel = floorInformation
            self.levelLabel.text = String(floorInformation)
            self.adjustAnnotations()
        }
        
        
        if (building == "Destination") {
            let text = NSMutableAttributedString(string: "You Reached Your Goal")
            startNavigationButton.setAttributedTitle(text, for: .disabled)
            self.removeMarkerOverlay()
            return
        }
        
        // STRUCTURE
        // Check if yor are at correct building
            // If yes check if you are on correct floor
                // If yes just show pin
                // If no highlight next stairs in the building
            // If not check if you are on groundfloor
                // If yes highlight correct building
                // If not highlight next stairs in the building
        
        // Only display markers if navigation has started
        if (self.startNavigationButton.isEnabled == false) {
            if let destination = self.currentPlace {
                
                localPosition = locationManager.location?.coordinate
                
                // Check if you are at correct building
                if (positionInsideOfRectangle(position: localPosition!, rectangle: getMarkerForDestinationBuilding(buildingName: (destination.building)!).boundingMapRect) || building == destination.building) {
                    
                    // Check if you are on correct floor
                    if (userLevel == destination.floor || floor == destination.floor) {
                        self.removeMarkerOverlay()
                        // you are on the correct floor --> remove building marker and show the pin
                        let text = NSMutableAttributedString(string: "Go to Pin")
                        text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                            NSAttributedStringKey.foregroundColor: UIColor.black],
                                           range: NSMakeRange(0, 5))
                        startNavigationButton.setAttributedTitle(text, for: .disabled)
                    }
                    else {
                        self.removeMarkerOverlay()
                        // you are not on the correct floor --> highlight closest stairs or stairs in this building
                        let text = NSMutableAttributedString(string: "Go to Stairs")
                        text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                            NSAttributedStringKey.foregroundColor: UIColor.black],
                                           range: NSMakeRange(0, 5))
                        startNavigationButton.setAttributedTitle(text, for: .disabled)
                        // user is in the correct building --> highlight the stairs in this building
                        highlightStairsForBuilding(buildingName: (destination.building)!)
                    }
                }
                    
                // Not at correct building
                else {
                    // Checks if you are at groundfloor to change buildings
                    if (userLevel == 0 || floor == 0) {
                        self.removeMarkerOverlay()
                        // You are on the groundfloor --> highlight correct building part
                        let text = NSMutableAttributedString(string: "Go to \((destination.building)!) Building")
                        text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                            NSAttributedStringKey.foregroundColor: UIColor.black],
                                           range: NSMakeRange(0, 5))
                        startNavigationButton.setAttributedTitle(text, for: .disabled)
                        
                        showMarkerForBuildingOnMap(buildingName: destination.building!)
                    }
                    // You are not on the ground floor
                    else {
                        self.removeMarkerOverlay()
                        let text = NSMutableAttributedString(string: "Go to Stairs")
                        text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                            NSAttributedStringKey.foregroundColor: UIColor.black],
                                           range: NSMakeRange(0, 5))
                        startNavigationButton.setAttributedTitle(text, for: .disabled)
                        
                        // Determines in which building the user is
                        let userInBuilding: String = determineInWhichBuildingUserIs()
                        
                        // Check whether the user is outside
                        if (userInBuilding == "Outside") {
                            // User is outside, highlight the building where she wants to go
                            showMarkerForBuildingOnMap(buildingName: destination.building!)
                            
                            // set text to "Go to Building ..."
                            let text = NSMutableAttributedString(string: "Go to \((destination.building)!) Building")
                            text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                                NSAttributedStringKey.foregroundColor: UIColor.black],
                                               range: NSMakeRange(0, 5))
                            startNavigationButton.setAttributedTitle(text, for: .disabled)
                        } else {
                            // User is inside a building part, highlights the stairs in this building which are closest to the user
                            highlightStairsForBuilding(buildingName: userInBuilding)
                        }
                    }
                }
            }
        }
    }
    
    // Returns the Polygon for a given building name
    // TODO: better default case
    func getMarkerForDestinationBuilding(buildingName: String) -> MKPolygon {
    
        switch buildingName {
        case "Hauptbau":
            return hauptbauMarkerAdjusted!
        case "E1":
            return e1Marker!
        case "E2":
            return e2Marker!
        case "E3":
            return e3Marker!
        default:
            return hauptbauMarker!
        }
    }
    
    // Adds the overlay for the given building part to the map
    // TODO: better default case
    func showMarkerForBuildingOnMap(buildingName: String) {
        
        switch buildingName {
        case "Hauptbau":
            self.mapView.add(hauptbauMarker!)
            break
        case "E1":
            self.mapView.add(e1Marker!)
            break
        case "E2":
            self.mapView.add(e2Marker!)
            break
        case "E3":
            self.mapView.add(e3Marker!)
            break
        default:
            self.mapView.add(hauptbauMarker!)
            break
        }
    }
    
    // Highlights the stairs in the building with the given name
    func highlightStairsForBuilding(buildingName: String) {
        
        switch buildingName {
        case "E1":
            self.mapView.add(stairsE1!)
        case "E2":
            self.mapView.add(stairsE2!)
        case "E3":
            self.mapView.add(stairsE3!)
        case "Hauptbau":
            localPosition = locationManager.location?.coordinate
            calculateClosestStairsAndHighlightThem(userLocation: localPosition!)
        default:
            self.mapView.add(stairsHauptbau_1!)
        }
    }
    
    // Calculates the closest stairs depending on the user position
    // This has only to be done for the decision between stairs_hauptbau_1
    // and stairs_hauptbau_2 because in the other building parts exists only one staircase
    func calculateClosestStairsAndHighlightThem(userLocation: CLLocationCoordinate2D) {
        
        // Coordinates of the staircases in the Hauptbau
        let stairsH_1 = CLLocationCoordinate2D(latitude: 50.77931288231099, longitude: 6.0590899734729975)
        let stairsH_2 = CLLocationCoordinate2D(latitude: 50.778722673651771, longitude: 6.0592344687667428)
        
        let distanceToStairsH_1 = distanceBetweenTwoPointsOnEarth(lat1d: stairsH_1.latitude, lon1d: stairsH_1.longitude, lat2d: userLocation.latitude, lon2d: userLocation.longitude)
        
        let distanceToStairsH_2 = distanceBetweenTwoPointsOnEarth(lat1d: stairsH_2.latitude, lon1d: stairsH_2.longitude, lat2d: userLocation.latitude, lon2d: userLocation.longitude)
        
        if (distanceToStairsH_1 <= distanceToStairsH_2) {
            self.mapView.add(stairsHauptbau_1!)
        } else if (distanceToStairsH_2 < distanceToStairsH_1) {
            self.mapView.add(stairsHauptbau_2!)
        }
    }
    
    // Returns the distance between two points on the Earth in meters
    func distanceBetweenTwoPointsOnEarth(lat1d: Double, lon1d: Double, lat2d: Double, lon2d: Double) -> Double {
        let earthRadiusKm = 6371.0
        var lat1r: Double
        var lon1r: Double
        var lat2r: Double
        var lon2r: Double
        var u: Double
        var v: Double
        
        lat1r = deg2rad(deg: lat1d)
        lon1r = deg2rad(deg: lon1d)
        lat2r = deg2rad(deg: lat2d)
        lon2r = deg2rad(deg: lon2d)
        
        u = sin((lat2r - lat1r)/2)
        v = sin((lon2r - lon1r)/2)
        
        return 1000.0 * 2.0 * earthRadiusKm * asin(sqrt(u * u + cos(lat1r) * cos(lat2r) * v * v))
    }
    
    // Converts decimal degrees to radians
    func deg2rad(deg: Double ) -> Double {
        return (deg * Double.pi / 180);
    }
    
    // Converts radians to decimal degrees
    func rad2deg(rad: Double ) -> Double {
        return (rad * 180 / Double.pi);
    }
    
    // Returns the building name in which the user currently is
    func determineInWhichBuildingUserIs() -> String {
        
        localPosition = locationManager.location?.coordinate
        
        // TODO: Test whether this "positionInsideOfRectangle(position: localPosition!, rectangle: hauptbau_1_Marker!.boundingMapRect) || positionInsideOfRectangle(position: localPosition!, rectangle: hauptbau_2_Marker!.boundingMapRect)" or hauptBauMArkerAdjusted is better
        if (positionInsideOfRectangle(position: localPosition!, rectangle: hauptbauMarkerAdjusted!.boundingMapRect)) {
            return "Hauptbau"
        } else if (positionInsideOfRectangle(position: localPosition!, rectangle: e1Marker!.boundingMapRect)) {
            return "E1"
            
        } else if (positionInsideOfRectangle(position: localPosition!, rectangle: e2Marker!.boundingMapRect)) {
            return "E2"
            
        } else if (positionInsideOfRectangle(position: localPosition!, rectangle: e3Marker!.boundingMapRect)) {
            return "E3"
            
        }
        
        return "Outside"
    }
    
    // IBAction for the Plus-Button
    @IBAction func plusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel + 1
        
        // Check that maximum level is 3
        if userLevel > 3 { userLevel = 3 }
        levelLabel.text = String(userLevel)
        
        self.adjustAnnotations()
        
        // Change building overlay to the previous level
        mapView.removeOverlays(mapView.overlays)
        mapView.add(mapOverlay)
        
        // Call this method at the end so that the green overlay is drawn on top of the building overlay
        self.adjustGuidance(building: nil, floor: nil)
    }
    
    // IBAction for the Minus-Button
    @IBAction func minusLevelButtonPressed(_ sender: UIButton) {
        userLevel = userLevel - 1
        
        // Check that minimum level is -1
        if userLevel < -1 { userLevel = -1 }
        levelLabel.text = String(userLevel)
        
        self.adjustAnnotations()
        
        // Change building overlay to the previous level
        mapView.removeOverlays(mapView.overlays)
        mapView.add(mapOverlay)
        
        // Call this method at the end so that the green overlay is drawn on top of the building overlay
        self.adjustGuidance(building: nil, floor: nil)
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
    
    // Creates all green overlays for building parts and stairs
    func loadOverlaysForBuildingParts() {
        e1Marker = BuildingOverlayLoader.loadE1Overlay()
        e2Marker = BuildingOverlayLoader.loadE2Overlay()
        e3Marker = BuildingOverlayLoader.loadE3Overlay()
        hauptbau_1_Marker = BuildingOverlayLoader.loadHauptbau1Marker()
        hauptbau_2_Marker = BuildingOverlayLoader.loadHauptbau2Marker()
        hauptbauMarker = BuildingOverlayLoader.loadHauptbauMarker()
        hauptbauMarkerAdjusted = BuildingOverlayLoader.loadHauptbauMarkerAdjusted()
        stairsE1 = BuildingOverlayLoader.loadStairsE1()
        stairsE2 = BuildingOverlayLoader.loadStairsE2()
        stairsE3 = BuildingOverlayLoader.loadStairsE3()
        stairsHauptbau_1 = BuildingOverlayLoader.loadStairsHauptbau1()
        stairsHauptbau_2 = BuildingOverlayLoader.loadStairsHauptbau2()
        }
    
    // Checks whether the given location is inside of the given rectangle
    // Mind that the given latitude value must greater than the maximum and smaller than the minimum
    // Is this really correct ???
    func positionInsideOfRectangle(position: CLLocationCoordinate2D, rectangle: MKMapRect) -> Bool {
        
        // calculate min latitude and min longitude
        let mapPointMin = MKMapPointMake(MKMapRectGetMinX(rectangle), MKMapRectGetMinY(rectangle))
        let coordinateMin = MKCoordinateForMapPoint(mapPointMin)
        
        // calculate max latitude and max longitude
        let mapPointMax = MKMapPointMake(MKMapRectGetMaxX(rectangle), MKMapRectGetMaxY(rectangle))
        let coordinateMax = MKCoordinateForMapPoint(mapPointMax)
        
        if (position.latitude <= coordinateMin.latitude && position.latitude >= coordinateMax.latitude) {
            if (position.longitude >= coordinateMin.longitude && position.longitude <= coordinateMax.longitude) {
                //print("The point is inside the MapRect.")
                return true
            } else {
                //print("The point is NOT inside the MapRect.")
                return false
            }
        } else {
            //print("The point is NOT inside the MapRect.")
            return false
        }
    }
    
    func removeMarkerOverlay() {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.add(mapOverlay)
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
                return MapOverlayView(overlay: mapOverlay, overlayImage: secondFloorImage)
            case 3:
                return MapOverlayView(overlay: mapOverlay, overlayImage: thirdFloorImage)
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
    
    // Resets the center of the map if the user swipes too far
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapView.region.center.latitude > 50.7800) || (mapView.region.center.longitude > 6.0615)
        || (mapView.region.center.latitude < 50.7779) || (mapView.region.center.longitude < 6.0580){
            
            // Center map on Informatikzentrum
            let position = CLLocationCoordinate2D(latitude: 50.77884, longitude: 6.05975)
            let span = MKCoordinateSpanMake(0.0026, 0.0026)
            let region = MKCoordinateRegionMake(position, span)
            mapView.setRegion(region, animated: true)
        }
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

