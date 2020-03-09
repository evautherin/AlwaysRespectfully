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


public enum BeaconMinorIdentifier: Hashable {
    case minor(UInt16)
    case any
}


public enum BeaconMajorIdentifier: Hashable {
    case major(UInt16, BeaconMinorIdentifier)
    case any
}


public struct BeaconIdentifier: Hashable {
    public let uuid: UUID
    public let major: BeaconMajorIdentifier
    
    public init(uuid: UUID, major: BeaconMajorIdentifier) {
        self.uuid = uuid
        self.major = major
    }
}


public enum Region<L>: Hashable where L: Location, L: Hashable {
    case circle(L, Double)
    case beaconArea(BeaconIdentifier)
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


public enum PredicateState {
    case opposite
    case identical

    public init(isIdentical: Bool) {
        self = isIdentical ? .identical : .opposite
    }
    
    public var isIdentical: Bool { self == .identical }

    public static func comparing(_ position: Position, _ otherPosition: Position) -> PredicateState {
        PredicateState(isIdentical: position == otherPosition)
    }

    public var description: String {
        switch (self) {
        case .opposite: return "opposite"
        case .identical: return "identical"
        }
    }
}


public protocol AbstractlyEquatable {
    associatedtype Abstraction
    
    func isEqual(to: Abstraction) -> Bool
}



public enum NotificationSound: Hashable {
    case `default`
    case named(String)
}


public protocol NotificationPresentation {
    var title: String { get }
    var body: String { get }
    var sound: NotificationSound { get }
}


extension Location {
    public var description: String {
        switch designation {
        case .unknown: return "(\(latitude), \(longitude))"
        case .name(let name): return name
        }
    }
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
}


extension Region {
    public var description: String {
        switch self {
        case .circle(let center, let radius): return "(\(center.description), \(radius))"
        case .beaconArea(let beaconIdentifier): return beaconIdentifier.description
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
}


extension PositionPredicate {
    public var id: String {
        description
    }
}



