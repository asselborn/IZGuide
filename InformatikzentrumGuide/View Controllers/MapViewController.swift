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
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
        let region = MKCoordinateRegionMake(position, span)
        mapView.region = region
        
        // Init overlay for indoor map, base floor
        self.mapView.add(mapOverlay)
        
        // loads the overlays for each part of the buidling (Hauptbau, E1, E2, ...) and stairs
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
            // If yes check if you are on correct floor
                // If yes just show pin
                // If no highlight next stairs
            // If not check if you are on groundfloor
                // If yes highlight correct building
                // If not highlight next stairs
        
        // Test
        if let destination = self.currentPlace {
            
            // TODO: Check if you are at correct building
            if (false) {
                // Check if you are on correct floor
                if (userLevel == destination.floor) {
                    // you are on the correct floor --> show the pin
                    let text = NSMutableAttributedString(string: "Go to Pin")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                }
                else {
                    // you are not on the correct floor --> highlight closest stairs
                    let text = NSMutableAttributedString(string: "Go to Stairs")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                    
                    // TODO
                    // Highlight stairs which are closest to the destination
                }
            }
            
            // Not at correct building
            else {
                // Check if you are at groundfloor to change buildings
                if (userLevel == 0) {
                    // you are on the groundfloor --> highlight correct building part
                    let text = NSMutableAttributedString(string: "Go to \((destination.building)!) Building")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                    
                    // TODO
                    // Highlight correct building part
                    if (destination.building == "Hauptbau") {
                        self.mapView.add(hauptbauMarker!)
                    }
                    else if (destination.building == "E1") {
                        self.mapView.add(e1Marker!)
                    }
                    else if (destination.building == "E2") {
                        self.mapView.add(e2Marker!)
                    }
                    else if (destination.building == "E3") {
                        self.mapView.add(e3Marker!)
                    }
                }
                else {
                    // you are not on the ground floor
                    let text = NSMutableAttributedString(string: "Go to Stairs")
                    text.setAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20),
                                        NSAttributedStringKey.foregroundColor: UIColor.black],
                                       range: NSMakeRange(0, 5))
                    startNavigationButton.setAttributedTitle(text, for: .disabled)
                    
                    // TODO
                    // Highlight stairs which are closest to the destination
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
    
    // Creates all green overlays for building parts and stairs
    func loadOverlaysForBuildingParts() {
        
        // Saves the marker points
        var vertices = Array<CLLocationCoordinate2D>()
        
        // Set markers for E1
        vertices.append(CLLocationCoordinate2D(latitude: 50.778859779739122, longitude: 6.0599764393620639))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778537071208433, longitude: 6.0601449308971498))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778512983783457, longitude: 6.0600404173008702))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778322445619636, longitude: 6.0601410238615419))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778295269956459, longitude: 6.060020393681433))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778277049869303, longitude: 6.0600291845452654))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778260991516902, longitude: 6.0599578808641734))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77860161308422, longitude: 6.0597708308144034))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778627244544765, longitude: 6.0598758328013931))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778791223662381, longitude: 6.0597879241627588))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778819634305677, longitude: 6.0599026937781062))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778839398213307, longitude: 6.059893414529161))
        e1Marker = MKPolygon(coordinates: vertices, count: 12)

        // Remove all entries
        vertices.removeAll()

        // Set markers for E2
        vertices.append(CLLocationCoordinate2D(latitude: 50.777985278837775, longitude: 6.0609780616144979))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778207584740812, longitude: 6.0608612639622734))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778145626680697, longitude: 6.0605782844072609))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778060124417721, longitude: 6.0606202218195557))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778042776105821, longitude: 6.0605920022533892))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778043271786885, longitude: 6.0605920022287592))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778032862801268, longitude: 6.0605606471646158))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778025179969575, longitude: 6.0605261565690105))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778021958132143, longitude: 6.0604916660093329))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778022453813406, longitude: 6.060456391530761))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777993209494156, longitude: 6.0604720690807961))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777973878498415, longitude: 6.060444241444765))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777958017155015, longitude: 6.0604085750517314))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777945377649189, longitude: 6.0603646779332898))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77794042098688, longitude: 6.0603356744999326))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777939181826895, longitude: 6.0603062791072286))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77794042098688, longitude: 6.0602811950523723))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777944386330404, longitude: 6.0602565029299917))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778062354913487, longitude: 6.060198496036203))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778054919915746, longitude: 6.0601612618774379))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778017249329963, longitude: 6.0601796829727199))
        vertices.append(CLLocationCoordinate2D(latitude: 50.777986765848709, longitude: 6.0600475997208489))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778221463351002, longitude: 6.0599311940054763))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778248477017996, longitude: 6.0600507352343973))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778296308552967, longitude: 6.0600205559677853))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778386767010971, longitude: 6.0604434575372697))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778303000017587, longitude: 6.0604850030138318))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778343892211353, longitude: 6.0606715657223216))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778477225294068, longitude: 6.0606045442472309))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778517621670829, longitude: 6.0607938505008665))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778326544016124, longitude: 6.0608922270669687))
        vertices.append(CLLocationCoordinate2D(latitude: 50.7783493444974, longitude: 6.0609956988090019))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77802765829631, longitude: 6.0611634484718202))
        e2Marker = MKPolygon(coordinates: vertices, count: 33)

        // Remove all entries
        vertices.removeAll()

        // Set markers for E3
        vertices.append(CLLocationCoordinate2D(latitude: 50.779409890441173, longitude: 6.0601506048238072))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778994426601344, longitude: 6.0603674114062036))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778944626611889, longitude: 6.0601475075938573))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779359811151352, longitude: 6.0599329133301847))
        e3Marker = MKPolygon(coordinates: vertices, count: 4)

        // Remove all entries
        vertices.removeAll()

        // Set markers for hauptbauMarker
        vertices.append(CLLocationCoordinate2D(latitude: 50.778712397629647, longitude: 6.0594885020227611))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778612990264293, longitude: 6.0595393472266643))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778545733176912, longitude: 6.0592447957003746))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77852429951983, longitude: 6.0592453801324364))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778523521567138, longitude: 6.0593654096926306))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77832031776299, longitude: 6.0593641006886862))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778318455402371, longitude: 6.0594266058571433))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778197154731259, longitude: 6.0594283021559594))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778203151605055, longitude: 6.0590828157073569))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778376106742996, longitude: 6.0590803568628715))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778374492077063, longitude: 6.0591871390437708))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778641781878292, longitude: 6.0591952681380894))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778666173871358, longitude: 6.0591830516174818))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778672795541752, longitude: 6.0592098862951298))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779192559351685, longitude: 6.0589426056825131))
        vertices.append(CLLocationCoordinate2D(latitude: 50.7791302450415, longitude: 6.0585672928961989))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779186975627766, longitude: 6.058536629292786))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779177640228681, longitude: 6.0584883625053285))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779465915788819, longitude: 6.0583498423452165))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779521599964312, longitude: 6.0586140379217737))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779452173229146, longitude: 6.0586486600343843))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779537417856858, longitude: 6.0590394361065858))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779608596443325, longitude: 6.0589628684168657))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779631314342112, longitude: 6.0590133326512827))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779655241777647, longitude: 6.0590895899113342))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779664665237533, longitude: 6.0591613969322529))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779669805298624, longitude: 6.0592386233286888))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77957899744348, longitude: 6.05923726850033))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779625258057649, longitude: 6.0594364312503801))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779740052730375, longitude: 6.0593781728233651))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779788883209108, longitude: 6.059593593824137))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779592021468318, longitude: 6.0596991429999623))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779580721904267, longitude: 6.0596534741482948))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779413990234076, longitude: 6.0597392521767057))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779280015717063, longitude: 6.059160042103894))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778702607124075, longitude: 6.0594540443294598))
        hauptbauMarker = MKPolygon(coordinates: vertices, count: 36)

        // Remove all entries
        vertices.removeAll()

        // Set markers for stairsHauptbau_1
        vertices.append(CLLocationCoordinate2D(latitude: 50.779351384988047, longitude: 6.0590414137151321))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779350330237293, longitude: 6.0591170981187119))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779297958066991, longitude: 6.0591170796415721))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779298826171583, longitude: 6.0590397774564364))
        stairsHauptbau_1 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()

        // Set markers for stairsHauptbau_2
        vertices.append(CLLocationCoordinate2D(latitude: 50.778707315955188, longitude: 6.0592568382664211))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778708350584992, longitude: 6.0591972783557182))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778744766169439, longitude: 6.0591997950439591))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77874580440394, longitude: 6.0592578200230429))
        stairsHauptbau_2 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()

//        // Set markers for stairsE1
//
//        stairsE1 = MKPolygon(coordinates: vertices, count: 4)
//
//        // Remove all entries
//        vertices.removeAll()
//
//        // Set markers for stairsE2
//
//        stairsE2 = MKPolygon(coordinates: vertices, count: 4)
//
//        // Remove all entries
//        vertices.removeAll()
//
//        // Set markers for stairsE3
//
//        stairsE3 = MKPolygon(coordinates: vertices, count: 4)
        

        // TODO
        // Use it in the navigation method
        
        // Testing whether a given point (user location) is inside a rectangle
        let mapRectTest: MKMapRect = (hauptbauMarker!.boundingMapRect)
        
        // calculate min latitude and longitude
        let mapPointTestMin = MKMapPointMake(MKMapRectGetMinX(mapRectTest), MKMapRectGetMinY(mapRectTest))
        let coordinateMin = MKCoordinateForMapPoint(mapPointTestMin)
        
        print("Min latitude: ", coordinateMin.latitude)
        print("Min longitude: ", coordinateMin.longitude)
        
        // calculate max latitude and longitude
        let mapPointTestMax = MKMapPointMake(MKMapRectGetMaxX(mapRectTest), MKMapRectGetMaxY(mapRectTest))
        let coordinateMax = MKCoordinateForMapPoint(mapPointTestMax)
        
        print("Max latitude: ", coordinateMax.latitude)
        print("Max longitude: ", coordinateMax.longitude)
        
        // enter another test position here
        let testPosition = CLLocationCoordinate2D(latitude: 50.779155215615987, longitude: 6.0606483179860016)
        
        let mapPoint = MKMapPointMake(testPosition.latitude, testPosition.longitude)
        
        print("tested position: latitude: ", testPosition.latitude, " longitude: ", testPosition.longitude)
        
        // try a given method which does not return the correct result
        // this somehow does not check the point correctly, the given point is inside the rectangle
        // but this method returns false because the minValue for latitude is greater than the maxValue for latitude
        // see output for this
        print("MKMapRectContainsPoint says: ", MKMapRectContainsPoint(mapRectTest, mapPoint))
        
        // use new method
        print("new method says: ", positionInsideOfRectangle(position: testPosition, rectangle: mapRectTest))
    }
    
    // checks whether the given location is inside of the given rectangle
    // mind that the given latitude value must greater than the maximum and smaller than the minimum
    // is this really correct ???
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

