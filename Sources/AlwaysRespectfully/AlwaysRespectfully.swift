//
//  AlwaysRespectful.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 03/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import UserNotifications
import AnyLogger


struct AlwaysRespectfully<R: RegionStore, N: PositionPredicateStore>
    where N.NativePredicate: PredicateEquatable {
    
    let regions: R
    let notifications: N
    
    enum Diffing {
        case set
        case update
    }


    func privateMonitor<Predicate>(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> where Predicate: PositionPredicate, Predicate: Hashable {
        
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
