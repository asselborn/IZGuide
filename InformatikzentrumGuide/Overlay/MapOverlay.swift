//
//  MapOverlay.swift
//  InformatikzentrumGuide
//
//  Created by David Asselborn on 02.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import UIKit
import MapKit

// Defines position and dimensions of an overlay
class MapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var imageName: String

    init(imageName: String) {
        let topLeft = CLLocationCoordinate2D(latitude: 50.78025, longitude: 6.05795)
        let topRight = CLLocationCoordinate2D(latitude: 50.78025, longitude: 6.06)
        let bottomLeft = CLLocationCoordinate2D(latitude: 50.7785, longitude: 6.05795)
        
        self.coordinate = CLLocationCoordinate2D(latitude: 50.7788, longitude: 6.0592)
        let origin = MKMapPointForCoordinate(topLeft)
        let size = MKMapSize(width: fabs(MKMapPointForCoordinate(topLeft).x - MKMapPointForCoordinate(topRight).x),
                             height: fabs(MKMapPointForCoordinate(topLeft).y - MKMapPointForCoordinate(bottomLeft).y))
        self.boundingMapRect = MKMapRect(origin: origin, size: size)
        
        self.imageName = imageName
    }
    
}
