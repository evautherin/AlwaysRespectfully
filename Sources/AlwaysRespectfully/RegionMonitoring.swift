//
//  RegionMonitoring.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 04/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import AnyLogger


//enum Direction {
//    case opposite
//    case identical
//
//    static func comparing(_ position: Position, _ otherPosition: Position) -> Direction {
//        switch (position, otherPosition) {
//        case (.inside, .inside), (.outside, .outside): return .identical
//        case (.inside, .outside), (.outside, .inside): return .opposite
//        }
//    }
//
//    var description: String {
//        switch (self) {
//        case .opposite: return "opposite"
//        case .identical: return "identical"
//        }
//    }
//}


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

#if DEBUG
extension Direction: CustomDebugStringConvertible {
    var debugDescription: String { description }
}
#endif


extension AlwaysRespectfully {
    func monitorRegions<Predicate>(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<(Predicate, Direction), Error> where Predicate: PositionPredicate, Predicate: Hashable {
        Empty<(Predicate, Direction), Error>().eraseToAnyPublisher()
    }
}


//struct RegionMonitoring<R: RegionStore, Predicate> where Predicate: PositionPredicate, Predicate: Hashable {
//    
//    static func monitor(
//        _ diffing: Diffing,
//        predicates: Set<Predicate>
//    ) -> AnyPublisher<(Predicate, Direction), Error> {
//        
//        let delegate = AlwaysRespectful
//        
//        func positionChangePublisher(predicate: Predicate) -> AnyPublisher<(Predicate, Direction), Never> {
//            let predicateRegion = predicate.region.erasedToAnyRegion
//            
////            func insideWhenPredicateMatches(with nativeRegion: CLRegion) -> Position? {
////                switch nativeRegion.extracted {
////                case predicateRegion: return .inside
////                default: return nil
////                }
////            }
////
////            func outsideWhenPredicateMatches(with nativeRegion: CLRegion) -> Position? {
////                switch nativeRegion.extracted {
////                case predicateRegion: return .outside
////                default: return nil
////                }
////            }
//
//            
////            func position(_ position: Position, whenPredicateMatchesWith nativeRegion: CLRegion) -> Position? {
////                switch nativeRegion.extracted {
////                case predicateRegion: return position
////                default: return nil
////                }
////            }
////
////            func insideWhenPredicateMatches(with nativeRegion: CLRegion) -> Position? {
////                position(.inside, whenPredicateMatchesWith: nativeRegion)
////            }
////
////            func outsideWhenPredicateMatches(with nativeRegion: CLRegion) -> Position? {
////                position(.outside, whenPredicateMatchesWith: nativeRegion)
////            }
//
//            
////            func predicateMatching(position: Position) -> (CLRegion) -> Position? {
////                return { (nativeRegion) -> Position? in
////                    switch nativeRegion.extracted {
////                    case predicateRegion: return position
////                    default: return nil
////                    }
////                }
////            }
//            
//            func predicateMatching(position: Position) -> (CLRegion) -> Position? {
//                return { (nativeRegion) -> Position? in
//                    (nativeRegion.abstractedRegion == predicateRegion) ? position : .none
//                }
//            }
//            
//            let insideWhenPredicateMatches = predicateMatching(position: .inside)
//            let outsideWhenPredicateMatches = predicateMatching(position: .outside)
//
//            let inside = Publishers.Merge(delegate.didEnterRegionSubject, delegate.insideRegionSubject)
//                .compactMap(insideWhenPredicateMatches)
//                .logDebug(".inside")
//
//            let outside = Publishers.Merge(delegate.didExitRegionSubject, delegate.outsideRegionSubject)
//                .compactMap(outsideWhenPredicateMatches)
//                .logDebug(".outside")
//
//            func predicateDirection(position: Position) -> (Predicate, Direction) {
//                (predicate, Direction.comparing(predicate.position, position))
//            }
//            
//            return Publishers.Merge(inside, outside)
//                .removeDuplicates()
//                .map(predicateDirection)
//                .logDebug(".positionChangePublisher")
//        }
//        
//        let positionChangePublishers = Publishers.MergeMany(predicates.map(positionChangePublisher))
//        
//        var setupRegionsMonitoring: AnyPublisher<Void, Error> {
//            
//            func regionsDifference() -> (added: Set<Region<AnyLocation>>, removed: Set<Region<AnyLocation>>) {
//                let target = Set(predicates.map(\.region.erasedToAnyRegion))
//                let current = Set(delegate.monitoredRegions.compactMap(\.abstractedRegion))
//                let removed = current.subtracting(target)
//                switch diffing {
//                    case .set: return (added: target, removed: removed)
//                    case .update: return (added: target.subtracting(current), removed: removed)
//                }
//            }
//            
//            let (addedRegions, removedRegions) = regionsDifference()
//            
//            func native(region: Region<AnyLocation>) -> CLRegion {
//                let nativeRegion = region.native
//                nativeRegion.notifyOnEntry = true
//                nativeRegion.notifyOnExit = true
//                return nativeRegion
//            }
//            
//            func stopRemovedRegionsMonitoring(on _: Subscription) {
//                removedRegions
//                    .map(native)
//                    .forEach(delegate.stopMonitoring)
//            }
//            
//            let startMonitoringPublishers = addedRegions
//                .map(native)
//                .map(delegate.startMonitoring)
//
//            return Publishers.zipMany(startMonitoringPublishers)
//                .handleEvents(receiveSubscription: stopRemovedRegionsMonitoring)
//                .logDebug(".setupRegionsMonitoring")
//        }
//        
//        return positionChangePublishers
//            .setFailureType(to: Error.self)
//            .combineLatest(setupRegionsMonitoring)
//            .map(\.0)
//            .eraseToAnyPublisher()
//    }
//}
