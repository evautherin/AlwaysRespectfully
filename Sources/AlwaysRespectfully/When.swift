//
//  When.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 11/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation


struct WhenLocation: Hashable, Location {
    var latitude: Double
    var longitude: Double
    var designation: Designation
    
    static func == (lhs: WhenLocation, rhs: WhenLocation) -> Bool {
        #warning("Needs coding")
        return true
    }

    public func hash(into hasher: inout Hasher) {
    }

}


struct When: Hashable, PositionPredicate {
    typealias L = WhenLocation

    var position: Position
    var region: Region<L>
    
    var activation: Activation
    
    var id: String
    
    
    static func == (lhs: When, rhs: When) -> Bool {
        #warning("Needs coding")
        return true
    }

    public func hash(into hasher: inout Hasher) {
    }

}
