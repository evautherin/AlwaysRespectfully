//
//  TypeBridges.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 05/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications


public struct AlwaysRespectful {
    static let identifier = "AlwaysRespectful"
}


extension Location {
    public var description: String {
        switch designation {
        case .unknown: return "(\(latitude), \(longitude))"
        case .name(let name): return name
        }
    }
}


extension CLLocationCoordinate2D: Location {
    public var designation: Designation { .unknown }
}


extension BeaconIdentifier {
    public var description: String {
        switch (major) {
            
        case .major(let major, let minor):
            switch minor {
            case .minor(let minor): return "\(uuid)-\(major)-\(minor)"
            case .any: return "\(uuid)-\(major)-*"
            }
            
        case .any: return "\(uuid)-*-*"
        }
    }

    var native: CLBeaconIdentityConstraint {
        switch (major) {
            
        case .major(let major, let minor):
            switch minor {
            case .minor(let minor): return CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
            case .any: return CLBeaconIdentityConstraint(uuid: uuid, major: major)
            }
            
        case .any:
            return CLBeaconIdentityConstraint(uuid: uuid)
        }
    }
}


extension CLBeaconIdentityConstraint {
    var extracted: BeaconIdentifier? {
        var majorIdentifier: BeaconMajorIdentifier {
            switch major {
                
            case .some(let major):
                switch minor {
                case .some(let minor): return BeaconMajorIdentifier.major(major, BeaconMinorIdentifier.minor(minor))
                case .none: return BeaconMajorIdentifier.major(major, BeaconMinorIdentifier.any)
                }

            case .none: return BeaconMajorIdentifier.any
            }
        }
        
        return  BeaconIdentifier(uuid: uuid, major: majorIdentifier)
    }
}


extension Region {
    public var description: String {
        switch self {
        case .circle(let center, let radius): return "(\(center.description), \(radius))"
        case .beaconArea(let beaconIdentifier): return beaconIdentifier.description
        }
    }

    public var native: CLRegion {
        switch self {
            
        case .circle(let center, let radius):
            return CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(center.latitude),
                    longitude: CLLocationDegrees(center.longitude)),
                radius: CLLocationDistance(radius),
                identifier: description
            )
            
        case .beaconArea(let beaconIdentifier):
            return CLBeaconRegion(
                beaconIdentityConstraint: beaconIdentifier.native,
                identifier: description
            )
        }
    }
    
    public func native(identifier: String) -> CLRegion {
        switch self {
            
        case .circle(let center, let radius):
            return CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(center.latitude),
                    longitude: CLLocationDegrees(center.longitude)),
                radius: CLLocationDistance(radius),
                identifier: identifier
            )
            
        case .beaconArea(let beaconIdentifier):
            return CLBeaconRegion(
                beaconIdentityConstraint: beaconIdentifier.native,
                identifier: identifier
            )
        }
    }
    
    public static func extract(region: CLRegion) -> Region<AnyLocation>? {
        region.abstractedRegion
    }
}


extension CLRegion {
    public var abstractedRegion: Region<AnyLocation>? {
        let circleOptional = self as? CLCircularRegion
        let beaconOptional = self as? CLBeaconRegion
        
        switch (circleOptional, beaconOptional) {
            
        case (.some(_), .some(_)):
            return .none
            
        case (.some(let circular), .none):
            let center = circular.center
            return Region.circle(
                AnyLocation(
                    latitude: center.latitude,
                    longitude: center.longitude
                ),
                circular.radius
            )
            
        case (.none, .some(let beacon)):
            return beacon.abstractedRegion
            
        case (.none, .none):
            return .none
        }
    }
}


extension Position {
    public var description: String {
        switch self {
        case .inside: return "inside"
        case .outside: return "outside"
        }
    }
}

extension CLRegion {
    public var abstractedPosition: Position? {
        switch (notifyOnEntry, notifyOnEntry) {
        case (false, false): return .none
        case (false, true): return .outside
        case (true, false): return .inside
        case (true, true): return .none
        }
    }
}


extension Activation {
    public var description: String {
        switch self {
        case .whenInUse: return "whenInUse"
        case .always: return "always"
        }
    }
}


extension PositionPredicate {
    public var description: String {
        "\(position.description) \(region.description)"
    }
        
    public var nativeRegion: CLRegion {
        let rawRegion = region.native
        switch position {
            
        case .inside:
            rawRegion.notifyOnEntry = true
            rawRegion.notifyOnExit = false
                
        case .outside:
            rawRegion.notifyOnEntry = false
            rawRegion.notifyOnExit = true
        }
        return rawRegion
    }
    
    public var notificationRequest: UNNotificationRequest? {
        
        guard let notificationContent = { () -> NotificationPresentation? in
                switch activation {
                case .whenInUse: return .none
                case .always(let content): return content
                }
            }() else { return .none }
        
        let content = UNMutableNotificationContent()
        #warning("Register category")
        content.categoryIdentifier = AlwaysRespectful.identifier
        content.title = notificationContent.title
        content.body = notificationContent.body
        content.sound = notificationContent.sound.native
//        content.userInfo = ["mission": identifier]

        let trigger = UNLocationNotificationTrigger(region: nativeRegion, repeats: true)

        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
    
//    public var request: UNNotificationRequest {
//        nativePredicate()
//    }
    
//    public static func extract(region: CLRegion) -> Region<AnyLocation>? {
//        region.extracted
//    }
}

extension PositionPredicate {
    public var id: String {
        description
    }
}

extension CLRegion {
    public var abstractedPredicate: AnyPositionPredicate? {
        guard
            let region = abstractedRegion,
            let position = abstractedPosition
            else { return .none }
        
        return AnyPositionPredicate(position, region)
    }
}


extension UNNotificationRequest {
    
    public var nativeRegion: CLRegion? {
        guard
            content.categoryIdentifier == AlwaysRespectful.identifier,
            let trigger = trigger as? UNLocationNotificationTrigger
            else { return .none }
        
        return trigger.region
    }
    
    public var abstractedPredicate: AnyPositionPredicate? {
        nativeRegion?.abstractedPredicate
    }
    
    public static func abstractPredicate(from request: UNNotificationRequest) -> AnyPositionPredicate? {
        request.abstractedPredicate
    }
}


extension NotificationSound {
    public var native: UNNotificationSound {
        switch self {
        case .`default`: return UNNotificationSound.default
        case .named(let name): return UNNotificationSound(named: UNNotificationSoundName(rawValue: name))
        }
    }
}


