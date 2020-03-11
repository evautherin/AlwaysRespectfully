//
//  When.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 11/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation


struct WhenLocation: Hashable, Location {
    let latitude: Double
    let longitude: Double
    let designation: Designation
    
    
    static func == (lhs: WhenLocation, rhs: WhenLocation) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}


public struct When: Hashable, PositionPredicate {

    public let position: Position
    public let region: Region
    public let activation: Activation
    public let id: String
    
    
    public static func == (lhs: When, rhs: When) -> Bool {
        lhs.position == rhs.position && lhs.region == rhs.region
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(region)
    }
}
