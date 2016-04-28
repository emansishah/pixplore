//
//  GeoLocation.swift
//  Pixplore
//
//  Created by Ali Shelton on 4/8/16.
//  Copyright © 2016 Mansi Shah. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

let kLatitudeKey = "latitude"
let kLongitudeKey = "longitude"
let kRadiusKey = "radius"
let kIdentifierKey = "identifier"
let kNoteKey = "note"
let kEventTypeKey = "eventType"

enum EventType: Int {
    case OnEntry = 0
    case OnExit
}

class Geotification: NSObject, NSCoding, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var identifier: String
    var note: String
    var eventType: EventType
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
        return "Radius: \(radius)m - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    
    // MARK: NSCoding
    
    required init?(coder decoder: NSCoder) {
        let latitude = decoder.decodeDoubleForKey(kLatitudeKey)
        let longitude = decoder.decodeDoubleForKey(kLongitudeKey)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDoubleForKey(kRadiusKey)
        identifier = decoder.decodeObjectForKey(kIdentifierKey) as! String
        note = decoder.decodeObjectForKey(kNoteKey) as! String
        eventType = EventType(rawValue: decoder.decodeIntegerForKey(kEventTypeKey))!
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(coordinate.latitude, forKey: kLatitudeKey)
        coder.encodeDouble(coordinate.longitude, forKey: kLongitudeKey)
        coder.encodeDouble(radius, forKey: kRadiusKey)
        coder.encodeObject(identifier, forKey: kIdentifierKey)
        coder.encodeObject(note, forKey: kNoteKey)
        coder.encodeInt(Int32(eventType.rawValue), forKey: kEventTypeKey)
    }
}
