//
//  Crawler.swift
//  CrawlerTest
//
//  Created by Lovis Suchmann on 22.01.18.
//  Copyright © 2018 Lovis Suchmann. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class Crawler: NSObject {
    
    static let UNIT_PREFIX = "https://www.campus.rwth-aachen.de/rwth/all/unit.asp?gguid="
    static let LECTURER_PREFIX = "https://www.campus.rwth-aachen.de/rwth/all/lecturer.asp?gguid="

    enum ItemType {
        case Unit
        case Lecturer
    }
    
    struct ItemKey : Hashable {
        var hashValue: Int {
            return keyString.hashValue
        }
        static func ==(lhs: ItemKey, rhs: ItemKey) -> Bool {
            return lhs.keyString.elementsEqual(rhs.keyString)
        }
        
        let keyString: String
        let itemType: ItemType
    }
    
    struct ItemBody {
        let data: String? // So far, this only contains the location, if found; it could be expanded
    }
    
    var items: Dictionary<ItemKey, ItemBody> = [:]
    var itemNames: Dictionary<ItemKey, String> = [:]
    var locations: Set<String> = []

    func getItemUrl(_ key: ItemKey) -> URL {
        switch key.itemType {
        case .Unit:
            return URL(string: Crawler.UNIT_PREFIX + key.keyString)!
        case .Lecturer:
            return URL(string: Crawler.LECTURER_PREFIX + key.keyString)!
        }
    }
    
    func getUnit(_ keyString: String) -> ItemBody? {
        return items[ItemKey(keyString: keyString, itemType: .Unit)]
    }
    func getLecturer(_ keyString: String) -> ItemBody? {
        return items[ItemKey(keyString: keyString, itemType: .Lecturer)]
    }

    // ----------------------------------------------------------

    let semaphore = DispatchSemaphore(value: 0)
    var visitedItemKeys: Set<ItemKey> = []
    var itemKeysToVisit: Set<ItemKey>
    
    let startItemKey = ItemKey(keyString: "0xE543C8C10685D51196700000F4B4937D", itemType: .Unit) // Department of Computer Science
    let maximumItemsToVisit = 1000

    override init() {
        itemKeysToVisit = [startItemKey];
        itemNames.updateValue("Fachgruppe Informatik", forKey: startItemKey)
        
        var keys = Set<String>()
        for (key, _) in Crawler.roomDictionary {
            if keys.contains(key) {
                print("dict contains duplicate key: \"\(key)\"")
            } else {
                keys.insert(key)
            }
        }
        
        super.init()
    }
    
    // ----------------------------------------------------------

    var places: [Place] = []
    
    // As only Units/Chairs/Institutions and Lecturers/Persons/People are fetchable via CAMPUS,
    // the room information has to be stored in the app for now.
    // Hopefully RWTHonline allows better integration!
    //
    // The coordinates of the Important Rooms and the 22.. rooms are accurate.
    // The other coordinates are dummies leading to the correct building part and floor, but that's it.
    static let roomDictionary: Dictionary<String, (Double, Double, String, Int16, String)> = [

        // Important Rooms
        "Hauptbau : Aula 2": (50.779346565464131, 6.058560755739216, "Hauptbau", 0, "URL"), //ok
        "Hauptbau : Mensa Ahornstraße": (50.779549951572719, 6.059539136996885, "Hauptbau", 0, "URL"), //ok
        "Hauptbau : AH I": (50.778609, 6.059407, "Hauptbau", 0, "http://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2350%7C009"), //ok
        "Hauptbau : AH II": (50.778609, 6.059407, "Hauptbau", 1, "http://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2350%7C111"), //ok
        "Hauptbau : AH III": (50.778609, 6.059407, "Hauptbau", 3, "http://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2350%7C314%2E1"), //ok
        "Hauptbau : AH IV": (50.779557255663697, 6.059148695737858, "Hauptbau", 0, "https://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2354%7C030"), //ok
        "E2 : AH V": (50.778009, 6.060307, "E2", 0, "http://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2356%7C050"),
        "E2 : AH VI": (50.778059, 6.060527, "E2", 0, "http://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2356%7C056"),
        "Hauptbau : Sporthallenkomplex Ahornstr.": (50.778521512278203, 6.0592188711139707, "Hauptbau", 0, "http://hochschulsport.rwth-aachen.de/"), //ok

        // 22.. rooms
        "Hauptbau : 2202": (50.779225, 6.059137, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2204": (50.779125, 6.059190, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2205": (50.779085, 6.059210, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2206": (50.779055, 6.059225, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2207": (50.779025, 6.059240, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2209": (50.778945, 6.059280, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2210": (50.778905, 6.059300, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2212": (50.778835, 6.059335, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2213": (50.778775, 6.059365, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2214": (50.778715, 6.059395, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2215": (50.778810, 6.059187, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2216": (50.778850, 6.059167, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2221": (50.779024, 6.059084, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2222": (50.779119421686843, 6.0590368397416343,"Hauptbau", 2, ""), //ok
        "Hauptbau : 2224": (50.779215, 6.058973, "Hauptbau", 2, ""), //ok
        "Hauptbau : 2225": (50.779215, 6.058973, "Hauptbau", 2, ""), //ok

        // Other rooms in the Computer Science Center
        "Hauptbau : 2001": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""), // based on i11 (2322)
        "Hauptbau : 2002": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2013": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2016": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2017": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2018": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2020": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""),
        "Hauptbau : 2301": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2302": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2304": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2305": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2306": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2307": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2308": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2309": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2311": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2313": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2314": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2315": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2316": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2317": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2318": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2319": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2320": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2321": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2322": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2323": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2324": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2325": (50.778985027020873, 6.0591560493499452,"Hauptbau", 3, ""),
        "Hauptbau : 2U13": (50.778985027020873, 6.0591560493499452,"Hauptbau",-1, ""),
        "Hauptbau : 4202": (50.778985027020873, 6.0591560493499452,"Hauptbau", 0, ""), // 4202?? probably a CAMPUS error??
        
        "E1 : 4001-4007": (50.778527255204068, 6.0599260221284084, "E1", 0, ""), // based on library
        "E1 : 4003": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4004": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4013": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4014": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4015": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4019": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4020": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4021": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4022": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4023": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4024": (50.778527255204068, 6.0599260221284084, "E1", 0, ""),
        "E1 : 4104": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4104a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4104b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4105": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4105a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4105b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4105c": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4107a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4108": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4108a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4108b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4114": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4115": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4116 b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4116a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4116b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4117a": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4117b": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4118": (50.778527255204068, 6.0599260221284084, "E1", 1, ""),
        "E1 : 4201": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4201a": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4201b": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4203": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4204": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4205": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4206": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4207": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4210": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4211": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4212": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4213 Sekr.": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4213": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4214": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4218": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4219": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4219/9219": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4220": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4222": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4224": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4225": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4226": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4227": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4228": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4229": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4230": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4231": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4232": (50.778527255204068, 6.0599260221284084, "E1", 2, ""),
        "E1 : 4301": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4302": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4303": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4304": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4305": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4306": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4307": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4308": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4309": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4310": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4311": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4312": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4314": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4315": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4316": (50.778527255204068, 6.0599260221284084, "E1", 3, ""),
        "E1 : 4U01a": (50.778527255204068, 6.0599260221284084, "E1",-1, ""),
        
        "E2 : 5052": (50.778139, 6.060307, "E2", 0, "URL"), // based on AH V (moved north)
        "E2 : 5053.5": (50.778139, 6.060307, "E2", 0, ""),
        "E2 : 5053.7": (50.778139, 6.060307, "E2", 0, ""),
        "E2 : 5053.8": (50.778139, 6.060307, "E2", 0, ""),
        "E2 : 5054": (50.778139, 6.060307, "E2", 0, "URL"),
        "E2 : 5055": (50.778139, 6.060307, "E2", 0, "URL"),
        "E2 : 5056": (50.778139, 6.060307, "E2", 0, "URL"),
        "E2 : 1.OG, 6123": (50.778276368134215, 6.0609121860457291, "E2", 1, ""), // based on kbsg
        "E2 : 6011": (50.778276368134215, 6.0609121860457291, "E2", 0, ""),
        "E2 : 6012": (50.778276368134215, 6.0609121860457291, "E2", 0, ""),
        "E2 : 6013": (50.778276368134215, 6.0609121860457291, "E2", 0, ""),
        "E2 : 6107": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6109 ": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6110": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6111": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6112": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6114": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6115": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6123b": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6125": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6125a": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6125b": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6129": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6130": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6132a": (50.778276368134215, 6.0609121860457291, "E2", 1, ""),
        "E2 : 6201": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6203": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6205": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6206": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6207": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6208": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6210": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6211": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6212": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6212a": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6213": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6214": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6230": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6231": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6234": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6235": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6236": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6237": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6239": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6240": (50.778276368134215, 6.0609121860457291, "E2", 2, ""),
        "E2 : 6301-6312": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6301": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6304": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6305": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6306": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6307": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6309": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6310": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6311": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6318-6329": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6320": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6321": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6323": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6324": (50.778276368134215, 6.0609121860457291, "E2", 3, ""),
        "E2 : 6U10": (50.778276368134215, 6.0609121860457291, "E2",-1, ""),
        "E2 : K111": (50.778276368134215, 6.0609121860457291, "E2", 0, ""), // K111?? probably a CAMPUS error??
        "E2 : Ruam 6U10c": (50.778276368134215, 6.0609121860457291, "E2",-1, ""),
        "E2 : Ruam 6U10d": (50.778276368134215, 6.0609121860457291, "E2",-1, ""),
        
        "E3 : 101": (50.779202137019055, 6.0601875398203111, "E3", 2, ""), // based on comsys
        "E3 : 102": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 106": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 107": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 108": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 109": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 113, 1. OG": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 114, 1. OG": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 114": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 115": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 116": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 117": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 121, 1. OG": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 205": (50.779202137019055, 6.0601875398203111, "E3", 3, ""),
        "E3 : 9001": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9002": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9003": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9004": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9005": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9006": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9007": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9008": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9009": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9010": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9011": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9012": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9013": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9014": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9015": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9016": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9017": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9018": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9028": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9029": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9030": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9031": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9032": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        "E3 : 9203": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 9204": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 9218": (50.779202137019055, 6.0601875398203111, "E3", 2, ""),
        "E3 : 9U07": (50.779202137019055, 6.0601875398203111, "E3",-1, ""),
        "E3 : EG": (50.779202137019055, 6.0601875398203111, "E3", 0, ""),
        
        // Rooms outside the Computer Science Center that are associated with the Department of Computer Science
        // These are not shown in the current version.
        "Sonstige (1090/Rogowski) : 430": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (1095) : 207": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (1095) : 430": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2165) : 122": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2165) : 124": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2165) : 127": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2165) : 208": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2165) : 210": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190 (Seffenter Weg 23)) : 004": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190 (Seffenter Weg 23)) : 008": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : 007": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : 008": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : 228": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : 229": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : 230": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2190) : K108": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : 111": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K005": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K101": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K103": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K106": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K107": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K108": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K109": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K110": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K111": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstr. 6)) : K204": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K005": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K105": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K106": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K108": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K109": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (2191 (Kopernikusstraße 6)) : K111": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (B-IT building, Bonn) : b-it 1.27": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Fraunhofer FIT) : C5-415": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (H) : 2U06": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (ICT cubes) : 399": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatik II, Uni Bonn) : N213": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatik II, Uni Bonn) : N216": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatik IV, Uni Bonn) : N 1.11": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum (ehem. PH)) : 4212": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum (ehem. PH)) : 4213": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 4U12": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 4U13": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 4U16": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6005": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6110": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6113": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6U08": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6U10": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6U10a": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6U10b": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : 6U10c": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Informatikzentrum) : AH 5": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (ITC) : 124": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski ) : 431a": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski Gebäude) : 119": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski Gebäude) : 430": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski) : 124/a": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski) : 423": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski) : 430": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (Rogowski) : 432": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Gebäude) : 212": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Center) : 127": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Center) : 204": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre (2165)) : 127": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre (2165)) : 129": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre (2165)) : 209": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre (2165)) : 211": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre (2165)) : 213": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 124": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 201": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 202": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 205": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 208": (50.779346565464131, 6.058560755739216, "Extern", 0, ""),
        "Sonstige (UMIC Research Centre) : 229": (50.779346565464131, 6.058560755739216, "Extern", 0, "")
    ]

    // ----------------------------------------------------------

    // Fetch data from storage into places array in the beginning
    func load() {
        DispatchQueue.main.sync {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Place")

            do {
                self.places = try managedContext.fetch(fetchRequest) as! [Place]
                print("fetched", self.places.count, "items.")
                
                //UNCOMMENT TO RESET COREDATA ENTITIES
                /*
                 for item in self.places {
                    managedContext.delete(item)
                }
                print("deleted all items.")
                try managedContext.save()
                self.places = []
                */
                
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    // Helper function: Used to enter data into persistent storage
    func save(name: String, latitude: Double, longitude: Double, category: String, floor: Int16, url: String?, building: String) {
        DispatchQueue.main.sync {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            
            let managedContext = appDelegate.persistentContainer.viewContext
            var place: NSManagedObject
            
            let existingItems = self.places.filter({ p in p.name == name })
            let itemAlreadyExists = existingItems.count > 0
            if itemAlreadyExists {
                assert(existingItems.count == 1)
                place = existingItems[0]
                //print("replaced existing item ", place as! Place)
            }
            else {
                let entity = NSEntityDescription.entity(forEntityName: "Place", in: managedContext)!
                place = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            place.setValue(name, forKeyPath: "name")
            place.setValue(latitude, forKey: "latitude")
            place.setValue(longitude, forKey: "longitude")
            place.setValue(category, forKey: "category")
            place.setValue(floor, forKey: "floor")
            place.setValue(url, forKey: "url")
            place.setValue(building, forKey: "building")
            
            do {
                try managedContext.save()
                if !itemAlreadyExists { self.places.append(place as! Place) /* ; print("created new item ", place as! Place) */ }
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    
    // Do the crawling
    func crawl() {
        
        guard visitedItemKeys.count <= maximumItemsToVisit else {
            print("Reached max number of items to visit")
            semaphore.signal()
            return
        }
        guard let itemKeyToVisit = itemKeysToVisit.popFirst() else {
            print("No more items to visit")
            semaphore.signal()
            return
        }
        if visitedItemKeys.contains(itemKeyToVisit) {
            crawl()
        } else {
            visit(itemKeyToVisit)
        }
    }
    
    
    // Create new task with corresponding parser function when an item is visited
    func visit(_ key: ItemKey) {
        
        visitedItemKeys.insert(key)
        
        let url = getItemUrl(key)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.crawl() }
            guard
                let data = data,
                error == nil,
                let document = String(data: data, encoding: .isoLatin1) else { return }
            
            switch (key.itemType) {
            case .Unit:
                self.parseUnit(document: document, itemKey: key)
                return
            case .Lecturer:
                self.parseLecturer(document: document, itemKey: key)
                return
            }
        }
        
        //print("\nVisiting " + String(describing:key.itemType) + " with url: " + url.absoluteString)
        task.resume()
    }
    
    
    // Helper function: Find (only new!) subitems of a given ItemType
    func findSubitems(text: String, pattern: String, itemType: ItemType) {
        
        func getMatches(pattern: String, text: String) -> [(String, String)] {
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: text, options: [.reportCompletion], range: NSRange(location: 0, length: text.characters.count))
            return matches.map { ((text as NSString).substring(with: $0.range(at:1)), (text as NSString).substring(with: $0.range(at:2))) }
        }
        
        getMatches(pattern: pattern, text: text).forEach {
            let subkey = ItemKey(keyString: $0.0, itemType: itemType)
            
            guard visitedItemKeys.contains(subkey) || itemKeysToVisit.contains(subkey) else {
                //print("        Found " + String(describing:itemType) + " (" + $0.0 + " , " + $0.1 + ").")
                itemKeysToVisit.insert(subkey)
                itemNames.updateValue($0.1, forKey: subkey)
                return
            }
        }
    }
    
    
    // Helper function: Find the location of an item
    func findItemLocation(text: String, pattern: String, forKey key: ItemKey) {
        
        func containsAny(_ text: String, _ elements: [String]) -> Bool {
            for el in elements {
                if text.contains(el) { return true; }
            }
            return false;
        }
        
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: text, options: [.reportCompletion], range: NSRange(location: 0, length: text.characters.count))
        var result: String = ""
        if matches.count > 0 {
            if matches[0].range(at: 1).length > 0 {
                let buildingMatch = ((text as NSString).substring(with: matches[0].range(at: 1)))
                var building = "Sonstige (" + buildingMatch + ")"
                if containsAny(buildingMatch, ["2359", "E3", "E III", "Erweiterungsbau 3", "Erw.-Bau 3", "Erw.-bau III"]) { building = "E3" }
                if containsAny(buildingMatch, ["2356", "E2", "E II",  "Erweiterungsbau 2", "Erw.-Bau 2", "Erw.-bau II" ]) { building = "E2" }
                if containsAny(buildingMatch, ["2353", "E1", "E I",   "Erweiterungsbau 1", "Erw.-Bau 1", "Erw.-bau I"  ]) { building = "E1" }
                if containsAny(buildingMatch, ["2350", "HBau", "Hauptbau", "Hauptgebäude", "Altbau", "Sammelbau"]       ) { building = "Hauptbau" }
                result += building + " : "
            }
            if matches[0].range(at: 2).length > 0 { result += ((text as NSString).substring(with: matches[0].range(at: 2))        ); }
            //print ("       ", key.itemType, "Location determined as:  ", result)
            locations.insert(result)
        } else {
            //print ("       ", key.itemType, "Location could not be resolved.")
        }
        items.updateValue(ItemBody(data: result == "" ? nil : result), forKey: key)
    }
    
    
    // Parse each visited Unit ("Chair")
    func parseUnit(document: String, itemKey key: ItemKey) {
        
        // Collect units below current unit
        let unitPattern = "<a href=\"unit\\.asp\\?gguid=(.*?)&amp;tguid=.*?\"[^>]*?>(.*?)</a>"
        findSubitems(text: document, pattern: unitPattern, itemType: .Unit)
        
        // Collect lecturers below current unit
        let lecturerPattern = "<a href=\"lecturer\\.asp\\?gguid=(.*?)&amp;tguid=.*?\"[^>]*?>(.*?)</a>"
        findSubitems(text: document, pattern: lecturerPattern, itemType: .Lecturer)
        
        // Determine room info of current unit
        let unitRoomPattern = "<td class=\"default\">Gebäude:</td><td class=\"default\"><span>(.*?)</span></td>.*?<td class=\"default\">Raum:</td><td class=\"default\"><span>(.*?)</span></td>"
        findItemLocation(text: document, pattern: unitRoomPattern, forKey: key)
    }
    
    
    // Parse each visited Lecturer ("Person")
    func parseLecturer(document: String, itemKey key: ItemKey) {
        
        // Determine room info of current lecturer
        let lecturerRoomPattern = "<p class=\"address\">Gebäude<img.*?>(.*?)</p><p class=\"address\">Raum<img.*?>(.*?)</p>"
        findItemLocation(text: document, pattern: lecturerRoomPattern, forKey: key)
    }
    
    
    // Main crawler function
    func run() -> [Place] {
        
        load()
 
        /*
        // Sample data for testing
        self.save(name: "Aula 2",
                  latitude: 50.779346565464131,
                  longitude: 6.058560755739216,
                  category: "Room",
                  floor: 0,
                  url: "https://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2352%7C021&expand=Campus+H%F6rn&building=Aula+und+Mensa&tguid=0x0C459501268AC043A64ED1E2F7FA6BEF",
                  building: "Hauptbau")
        self.save(name: "AH 4",
                  latitude: 50.779557255663697,
                  longitude: 6.059148695737858,
                  category: "Room",
                  floor: 0,
                  url: "https://www.campus.rwth-aachen.de/rwth/all/room.asp?room=2354%7C030&expand=Campus+H%F6rn&building=H%F6rsaal+an+der+Mensa&tguid=0x0C459501268AC043A64ED1E2F7FA6BEF",
                  building: "Hauptbau")
        self.save(name: "2222",
                  latitude: 50.779119421686843,
                  longitude: 6.0590368397416343,
                  category: "Room",
                  floor: 2,
                  url: "http://hci.rwth-aachen.de",
                  building: "Hauptbau")
        self.save(name: "Mensa Ahornstr.",
                  latitude: 50.779549951572719,
                  longitude: 6.059539136996885,
                  category: "Room",
                  floor: 0,
                  url: "http://www.studierendenwerk-aachen.de/de/Gastronomie/mensa-ahornstrasse-wochenplan.html",
                  building: "Hauptbau")
        self.save(name: "Informatik 10 - Media Computing Group",
                  latitude: 50.779021862771607,
                  longitude: 6.0591637127093829,
                  category: "Chair",
                  floor: 2,
                  url: "http://hci.rwth-aachen.de",
                  building: "Hauptbau")
        self.save(name: "Communication and Distributed Systems",
                  latitude: 50.779202137019055,
                  longitude: 6.0601875398203111,
                  category: "Chair",
                  floor: 1,
                  url: "https://www.comsys.rwth-aachen.de/home/",
                  building: "E3")
        self.save(name: "Prof. Dr.-Ing Klaus Wehrle",
                  latitude: 50.779202137019055,
                  longitude: 6.0601875398203111,
                  category: "Person",
                  floor: 1,
                  url: "https://www.comsys.rwth-aachen.de/team/klaus/",
                  building: "E3")
        self.save(name: "Prof. Dr. Jan Borchers",
                  latitude: 50.779021862771607,
                  longitude: 6.0591637127093829,
                  category: "Person",
                  floor: 2,
                  url: "http://hci.rwth-aachen.de/borchers",
                  building: "Hauptbau")
        self.save(name: "Computer Science Library",
                  latitude: 50.778527255204068,
                  longitude: 6.0599260221284084,
                  category: "Room",
                  floor: 0,
                  url: "http://tcs.rwth-aachen.de/www-bib/index.php",
                  building: "E1")
        self.save(name: "Sporthallenkomplex Ahornstr.",
                  latitude: 50.778521512278203,
                  longitude: 6.0592188711139707,
                  category: "Room",
                  floor: 0,
                  url: "http://hochschulsport.rwth-aachen.de/",
                  building: "Hauptbau")
        self.save(name: "InfoSphere - Schülerlabor Informatik",
                  latitude: 50.779014572047124,
                  longitude: 6.060270794456585,
                  category: "Room",
                  floor: -1,
                  url: "http://schuelerlabor.informatik.rwth-aachen.de/",
                  building: "E3")
        self.save(name: "Informatik 11 - Embedded Software",
                  latitude: 50.778985027020873,
                  longitude: 6.0591560493499452,
                  category: "Chair",
                  floor: 3,
                  url: "https://embedded.rwth-aachen.de/",
                  building: "Hauptbau")
        self.save(name: "Prof. Dr.-Ing. Stefan Kowalewski",
                  latitude: 50.778985027020873,
                  longitude: 6.0591560493499452,
                  category: "Person",
                  floor: 3,
                  url: "https://embedded.rwth-aachen.de/doku.php?id=lehrstuhl:mitarbeiter:kowalewski",
                  building: "Hauptbau")
        self.save(name: "Knowledge-Based Systems Group",
                  latitude: 50.778276368134215,
                  longitude: 6.0609121860457291,
                  category: "Chair",
                  floor: 2,
                  url: "https://kbsg.rwth-aachen.de/",
                  building: "E2")
        self.save(name: "Prof. Gerhard Lakemeyer, Ph.D.",
                  latitude: 50.778276368134215,
                  longitude: 6.0609121860457291,
                  category: "Person",
                  floor: 2,
                  url: "https://kbsg.rwth-aachen.de/user/7",
                  building: "E2")
        */
        
        for i in Crawler.roomDictionary {
            if i.value.2 == "Extern" { continue }
            save(name: i.key, latitude: i.value.0, longitude: i.value.1, category: "Room", floor: i.value.3, url: i.value.4, building: i.value.2)
        }

        crawl()
        semaphore.wait()
        
        for lec in items.filter ({ (key, _) in key.itemType == .Lecturer }) {
            if let location = lec.value.data, let (latitude, longitude, building, floor, _) = Crawler.roomDictionary[location], building != "Extern" {
                save(name: itemNames[lec.key]!, latitude: latitude, longitude: longitude, category: "Person", floor: floor, url: getItemUrl(lec.key).absoluteString, building: building)
            }
        }
        for uni in items.filter ({ (key, _) in key.itemType == .Unit     }) {
            if let location = uni.value.data, let (latitude, longitude, building, floor, _) = Crawler.roomDictionary[location], building != "Extern" {
                save(name: itemNames[uni.key]!, latitude: latitude, longitude: longitude, category: "Chair", floor: floor, url: getItemUrl(uni.key).absoluteString, building: building)
            }
        }

        return self.places
    }
}

