//
//  BuildingOverlayLoader.swift
//  InformatikzentrumGuide
//
//  Created by Lucas Dührsen on 24.01.18.
//  Copyright © 2018 David Asselborn. All rights reserved.
//

import MapKit

class BuildingOverlayLoader {
    // Saves the marker points
    static var vertices = Array<CLLocationCoordinate2D>()
    
    // Creates all green overlays for building parts and stairs
    static func loadE1Overlay() -> MKPolygon {
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
        let e1Marker = MKPolygon(coordinates: vertices, count: 12)
        
        // Remove all entries
        vertices.removeAll()
        
        return e1Marker
    }
    
    static func loadE2Overlay() -> MKPolygon {
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
        let e2Marker = MKPolygon(coordinates: vertices, count: 33)
        
        // Remove all entries
        vertices.removeAll()
        
        return e2Marker
    }
    
    static func loadE3Overlay() -> MKPolygon {
        // Set markers for E3
        vertices.append(CLLocationCoordinate2D(latitude: 50.779409890441173, longitude: 6.0601506048238072))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778994426601344, longitude: 6.0603674114062036))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778944626611889, longitude: 6.0601475075938573))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779359811151352, longitude: 6.0599329133301847))
        let e3Marker = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return e3Marker
    }
    
    static func loadHauptbau1Marker() -> MKPolygon {
        // Set markers for hauptbau_1_Marker
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
        let hauptbau_1_Marker = MKPolygon(coordinates: vertices, count: 21)
        
        // Remove all entries
        vertices.removeAll()
        
        return hauptbau_1_Marker
    }
    
    static func loadHauptbau2Marker() -> MKPolygon {
        // Set markers for hauptbau_2_Marker
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
        vertices.append(CLLocationCoordinate2D(latitude: 50.779280015717063, longitude: 6.059160042103894))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778702607124075, longitude: 6.0594540443294598))
        let hauptbau_2_Marker = MKPolygon(coordinates: vertices, count: 17)
        
        // Remove all entries
        vertices.removeAll()
        
        return hauptbau_2_Marker
    }
    
    static func loadHauptbauMarker() -> MKPolygon {
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
        let hauptbauMarker = MKPolygon(coordinates: vertices, count: 36)
        
        vertices.removeAll()
        
        return hauptbauMarker
    }
    
    static func loadStairsHauptbau1() -> MKPolygon {
        // Set markers for stairsHauptbau_1
        vertices.append(CLLocationCoordinate2D(latitude: 50.779351384988047, longitude: 6.0590414137151321))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779350330237293, longitude: 6.0591170981187119))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779297958066991, longitude: 6.0591170796415721))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779298826171583, longitude: 6.0590397774564364))
        let stairsHauptbau_1 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return stairsHauptbau_1
    }
    
    static func loadStairsHauptbau2() -> MKPolygon {
        // Set markers for stairsHauptbau_2
        vertices.append(CLLocationCoordinate2D(latitude: 50.778707315955188, longitude: 6.0592568382664211))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778708350584992, longitude: 6.0591972783557182))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778744766169439, longitude: 6.0591997950439591))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77874580440394, longitude: 6.0592578200230429))
        let stairsHauptbau_2 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return stairsHauptbau_2
    }
    
    static func loadStairsE1() -> MKPolygon {
        // Set markers for stairsE1
        vertices.append(CLLocationCoordinate2D(latitude: 50.778525685736639, longitude: 6.0600043258062968))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778562988496816, longitude: 6.0600031098317961))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778562725833524, longitude: 6.0599477111732973))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778526099586401, longitude: 6.059947383918546))
        let stairsE1 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return stairsE1
    }
    
    static func loadStairsE2() -> MKPolygon {
        // Set markers for stairsE2
        vertices.append(CLLocationCoordinate2D(latitude: 50.77822280564564, longitude: 6.0609174448337688))
        vertices.append(CLLocationCoordinate2D(latitude: 50.77826108757688, longitude: 6.0609184265904927))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778261915281035, longitude: 6.0608585394322647))
        vertices.append(CLLocationCoordinate2D(latitude: 50.778222612147289, longitude: 6.0608593050122339))
        let stairsE2 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return stairsE2
    }
    
    static func loadStairsE3() -> MKPolygon {
        // Set markers for stairsE3
        vertices.append(CLLocationCoordinate2D(latitude: 50.779260900554334, longitude: 6.0602272628574623))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779230501889003, longitude: 6.0602282380227539))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779230229176704, longitude: 6.0601806887398331))
        vertices.append(CLLocationCoordinate2D(latitude: 50.779260899477634, longitude: 6.0601829829127025))
        let stairsE3 = MKPolygon(coordinates: vertices, count: 4)
        
        // Remove all entries
        vertices.removeAll()
        
        return stairsE3
    }
    
    // Not functional
    static func testingMethod() {
        //        // ====================================================================================
        //        // TESTING
        //        // ====================================================================================
        //
        //        // Testing whether a given point (user location) is inside a rectangle
        //        let mapRectTest: MKMapRect = (hauptbau_1_Marker!.boundingMapRect)
        //
        //        // calculate min latitude and longitude
        //        let mapPointTestMin = MKMapPointMake(MKMapRectGetMinX(mapRectTest), MKMapRectGetMinY(mapRectTest))
        //        let coordinateMin = MKCoordinateForMapPoint(mapPointTestMin)
        //
        //        print("Min latitude: ", coordinateMin.latitude)
        //        print("Min longitude: ", coordinateMin.longitude)
        //
        //        // calculate max latitude and longitude
        //        let mapPointTestMax = MKMapPointMake(MKMapRectGetMaxX(mapRectTest), MKMapRectGetMaxY(mapRectTest))
        //        let coordinateMax = MKCoordinateForMapPoint(mapPointTestMax)
        //
        //        print("Max latitude: ", coordinateMax.latitude)
        //        print("Max longitude: ", coordinateMax.longitude)
        //
        //        // enter another test position here
        //        let testPosition = CLLocationCoordinate2D(latitude: 50.779155215615987, longitude: 6.0606483179860016)
        //
        //        let mapPoint = MKMapPointMake(testPosition.latitude, testPosition.longitude)
        //
        //        print("tested position: latitude: ", testPosition.latitude, " longitude: ", testPosition.longitude)
        //
        //        // try a given method which does not return the correct result
        //        // this somehow does not check the point correctly, the given point is inside the rectangle
        //        // but this method returns false because the minValue for latitude is greater than the maxValue for latitude
        //        // see output for this
        //        print("MKMapRectContainsPoint says: ", MKMapRectContainsPoint(mapRectTest, mapPoint))
        //
        //        // use new method
        //        print("new method says: ", positionInsideOfRectangle(position: testPosition, rectangle: mapRectTest))
        //
        //        // ====================================================================================
        //        // TESTING
        //        // ====================================================================================
    }
}
