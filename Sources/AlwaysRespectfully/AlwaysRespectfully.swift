//
//  AlwaysRespectfully.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 03/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
import AnyLogger


public struct AlwaysRespectfully<R: RegionStore, N: PositionPredicateStore>
    where N.NativePredicate.Abstraction: Hashable, N.NativePredicate.Abstraction: PositionPredicate {
    
    public typealias Predicate = N.NativePredicate.Abstraction
    
    public let regions: R
    public let notifications: N
    
    public init(regions: R, notifications: N) {
        self.regions = regions
        self.notifications = notifications
    }

    
    public func monitor(
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> {
        privateMonitor(.set, predicates: predicates)
    }

    
    enum Diffing {
        case set
        case update
    }


    func privateMonitor(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<Predicate, Error> {
        
        func adjustNotifcationMasking(predicate: Predicate, state: PredicateState) {
            log.debug("adjustNotifcationMasking \(state.description) \(predicate.description)")
            let identifiers = [predicate.id]
            
            switch state {
            case .identical: notifications.mask(predicateIdentifiers: identifiers)
            case .opposite: notifications.unmask(predicateIdentifiers: identifiers)
            }
        }
        
        func identicalState(predicate: Predicate, state: PredicateState) -> Predicate? {
            state.isIdentical ? predicate : .none
        }
        
        return monitorRegions(diffing, predicates: predicates)
            .handleEvents(receiveOutput: adjustNotifcationMasking)
            .combineLatest(setNotifications(diffing, predicates: predicates))
            .map(\.0)
            .compactMap(identicalState)
            .logDebug(".predicates monitoring")
    }
}


#if DEBUG
extension PredicateState: CustomDebugStringConvertible {
    public var debugDescription: String { description }
}
#endif
