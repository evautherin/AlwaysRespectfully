//
//  Types.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 04/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation


public enum Designation {
    case unknown
    case name(String)
}

public protocol Location {
    var latitude: Double { get }
    var longitude: Double { get }
    var designation: Designation { get }
    
}

public struct AnyLocation: Location, Hashable {
    public let latitude: Double
    public let longitude: Double
    public let designation: Designation
    
    public init(latitude: Double, longitude: Double, designation: Designation = .unknown) {
        self.latitude = latitude
        self.longitude = longitude
        self.designation = designation
    }
    
    public static func == (lhs: AnyLocation, rhs: AnyLocation) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}


public enum BeaconMinorIdentifier: Hashable {
    case minor(UInt16)
    case any
}


public enum BeaconMajorIdentifier: Hashable {
    case major(UInt16, BeaconMinorIdentifier)
    case any
}


public struct BeaconIdentifier: Hashable {
    let uuid: UUID
    let major: BeaconMajorIdentifier
}


public enum Region<L>: Hashable where L: Location, L: Hashable {
    case circle(L, Double)
    case beaconArea(BeaconIdentifier)

    public func eraseToAnyRegion() -> Region<AnyLocation> {
        switch self {
        case .circle(let center, let radius):
            let anyCenter = AnyLocation(
                latitude: center.latitude,
                longitude: center.longitude,
                designation: center.designation
            )
            return Region<AnyLocation>.circle(anyCenter, radius)
            
        case .beaconArea(let identifier):
            return Region<AnyLocation>.beaconArea(identifier)
        }
    }
    
    var erasedToAnyRegion: Region<AnyLocation> {
        eraseToAnyRegion()
    }
}


public enum Position: Hashable {
    case inside
    case outside
}


public enum Activation {
    case whenInUse
    case always(NotificationPresentation)
}


public protocol PositionPredicate: Identifiable {
    associatedtype L: Location, Hashable
    
    var position: Position { get }
    var region: Region<L> { get }
    
    var activation: Activation { get }
    
    var id: String { get }
}

public struct AnyPositionPredicate: PositionPredicate, Hashable {
    public let position: Position
    public let region: Region<AnyLocation>
    
    public let activation: Activation

    public init(_ position: Position, _ region: Region<AnyLocation>, _ activation: Activation = .whenInUse) {
        self.position = position
        self.region = region
        self.activation = activation
    }
    
    public static func == (lhs: AnyPositionPredicate, rhs: AnyPositionPredicate) -> Bool {
        lhs.position == rhs.position && lhs.region == rhs.region
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(region)
    }
}

public extension PositionPredicate {
    func eraseToAnyPositionPredicate() -> AnyPositionPredicate {
        let anyRegion = region.eraseToAnyRegion()
        return AnyPositionPredicate(position, anyRegion, activation)
    }
    
    var erasedToAnyPositionPredicate: AnyPositionPredicate {
        eraseToAnyPositionPredicate()
    }
}


//public enum RegionCrossing<T>: Equatable where T: PositionPredicate, T: Equatable {
//    case identical(T)
//    case opposite(T)
//}
//
//extension RegionCrossing {
//    static func comparePredicates<T, U>(predicateA: T, predicateB: U) -> RegionCrossing<T>
//        where T: PositionPredicate, T: Equatable, U: PositionPredicate, U: Equatable  {
//
//        switch (predicateA.position, predicateB.position) {
//        case (.inside, .inside), (.outside, .outside): return .identical(predicateA)
//        case (.inside, .outside), (.outside, .inside): return .opposite(predicateA)
//        }
//    }
//}


public enum NotificationSound: Hashable {
    case `default`
    case named(String)
}


public protocol NotificationPresentation {
    var title: String { get }
    var body: String { get }
    var sound: NotificationSound { get }
}


//public struct AnyPresentablePredicate: PositionPredicate, NotificationPresentation, Hashable {
//    public let position: Position
//    public let region: Region<AnyLocation>
//    public let localizedTitleKey: String
//    public let localizedBodyKey: String
//    public let sound = NotificationSound.default
//    
//    public init(_ position: Position, _ region: Region<AnyLocation>, titleKey: String, bodyKey: String) {
//        self.position = position
//        self.region = region
//        self.localizedTitleKey = titleKey
//        self.localizedBodyKey = bodyKey
//    }
//}


