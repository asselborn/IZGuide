//
//  MapViewController.swift
//  InformatikzentrumGuide
//
//  Created by David Asselborn on 02.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    let mapOverlay = MapOverlay(imageName: "OverlayBase")
    
    let locationManager = CLLocationManager()
    var localPosition: CLLocationCoordinate2D?

    
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
        
        // Test marker overlay for later navigation
        var vertices = Array<CLLocationCoordinate2D>()
        vertices.append(CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0592))
        vertices.append(CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0594))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779, longitude: 6.0594))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779, longitude: 6.0592))
        let marker = MKPolygon(coordinates: vertices, count: 4)
        self.mapView.add(marker)
        
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

extension MapViewController: UISearchBarDelegate {
    
}
