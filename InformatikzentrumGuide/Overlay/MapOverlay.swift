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

    override init() {
        let topLeft = CLLocationCoordinate2D(latitude: 50.779817, longitude: 6.058315)
        let topRight = CLLocationCoordinate2D(latitude: 50.779822, longitude: 6.061283)
        let bottomLeft = CLLocationCoordinate2D(latitude: 50.777923, longitude: 6.058065)
        
        self.coordinate = CLLocationCoordinate2D(latitude: 50.77885, longitude: 6.05975)
        let origin = MKMapPointForCoordinate(topLeft)
        let size = MKMapSize(width: fabs(MKMapPointForCoordinate(topLeft).x - MKMapPointForCoordinate(topRight).x),
                             height: fabs(MKMapPointForCoordinate(topLeft).y - MKMapPointForCoordinate(bottomLeft).y))
        self.boundingMapRect = MKMapRect(origin: origin, size: size)
    }

}
