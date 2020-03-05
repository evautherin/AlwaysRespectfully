//
//  AlwaysRespectfully.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 03/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import AnyLogger


public struct AlwaysRespectfully<R: RegionStore, N: PositionPredicateStore> {
    
    public let regions: R
    public let notifications: N
    
    public init(regions: R, notifications: N) {
        self.regions = regions
        self.notifications = notifications
    }

    
    public func monitor<Predicate>(
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> where Predicate: Hashable, Predicate: PositionPredicate {
        privateMonitor(.set, predicates: predicates)
    }

    
    enum Diffing {
        case set
        case update
    }


    enum Direction {
        case opposite
        case identical

        init(isIdentical: Bool) {
            self = isIdentical ? .identical : .opposite
        }
        
        var isIdentical: Bool { self == .identical }

        static func comparing(_ position: Position, _ otherPosition: Position) -> Direction {
            Direction(isIdentical: position == otherPosition)
        }

        var description: String {
            switch (self) {
            case .opposite: return "opposite"
            case .identical: return "identical"
            }
        }
    }


    func privateMonitor<Predicate>(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> where Predicate: Hashable, Predicate: PositionPredicate {
        
        func adjustNotifcationMasking(predicate: Predicate, direction: Direction) {
            log.debug("adjustNotifcationMasking \(direction.description) \(predicate.description)")
            let identifiers = [predicate.id]
            
            switch direction {
            case .identical: notifications.mask(predicateIdentifiers: identifiers)
            case .opposite: notifications.unmask(predicateIdentifiers: identifiers)
            }
        }
        
        func identicalDirection(predicate: Predicate, direction: Direction) -> Predicate? {
            direction.isIdentical ? predicate : .none
        }
        
        return monitorRegions(diffing, predicates: predicates)
            .handleEvents(receiveOutput: adjustNotifcationMasking)
            .combineLatest(setNotifications(diffing, predicates: predicates))
            .map(\.0)
            .compactMap(identicalDirection)
            .logDebug(".predicates monitoring")
    }
}


#if DEBUG
extension AlwaysRespectfully.Direction: CustomDebugStringConvertible {
    var debugDescription: String { description }
}
#endif
