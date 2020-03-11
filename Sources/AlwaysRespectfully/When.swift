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


struct When: Hashable, PositionPredicate {
    typealias L = WhenLocation

    let position: Position
    let region: Region<L>
    let activation: Activation
    let id: String
    
    
    static func == (lhs: When, rhs: When) -> Bool {
        lhs.position == rhs.position && lhs.region == rhs.region
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(region)
    }
}
