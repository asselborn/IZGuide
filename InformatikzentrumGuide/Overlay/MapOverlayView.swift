//
//  MapOverlayView.swift
//  InformatikzentrumGuide
//
//  Created by David Asselborn on 02.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import UIKit
import MapKit

// Defines custom rendering of overlay image
class MapOverlayView: MKOverlayRenderer {
    var overlayImage: UIImage
    
    init(overlay: MKOverlay, overlayImage: UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        guard let imageReference = overlayImage.cgImage else { return }
        
        let rect = self.rect(for: overlay.boundingMapRect)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -rect.size.height)
        context.draw(imageReference, in: rect)
    }
}
