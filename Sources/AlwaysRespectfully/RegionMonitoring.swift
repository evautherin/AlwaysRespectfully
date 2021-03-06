//
//  RegionMonitoring.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 04/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine
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


extension AlwaysRespectfully {
    func monitorRegions(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<(Predicate, PredicateState), Error> {

        func stateChangePublisher(predicate: Predicate) -> AnyPublisher<(Predicate, PredicateState), Never> {
                        
            func predicateMatching(position: Position) -> (R.NativeRegion) -> Position? {
                return { (nativeRegion) -> Position? in
                    nativeRegion.isEqual(to: predicate.region) ? position : .none
                }
            }
            
            let insideWhenPredicateMatches = predicateMatching(position: .inside)
            let outsideWhenPredicateMatches = predicateMatching(position: .outside)

            let inside = regions.insideRegionPublisher
                .compactMap(insideWhenPredicateMatches)
                .logDebug(".inside")

            let outside = regions.outsideRegionPublisher
                .compactMap(outsideWhenPredicateMatches)
                .logDebug(".outside")

            func predicateState(position: Position) -> (Predicate, PredicateState) {
                (predicate, PredicateState.comparing(predicate.position, position))
            }
            
            return Publishers.Merge(inside, outside)
                .removeDuplicates()
                .map(predicateState)
                .logDebug(".positionChangePublisher")
        }
        let positionChangePublishers = Publishers.MergeMany(predicates.map(stateChangePublisher))
        
        
        var regionsDifference: (added: [Region], removed: [R.NativeRegion]) {
                
            let predicateRegions = predicates.map(\.region)
            let nativeRegions = regions.storedRegions

            func notContainedByRegions(nativeRegion: R.NativeRegion) -> Bool {
                func isEqual(predicate: Region) -> Bool {
                    nativeRegion.isEqual(to: predicate)
                }
                return predicateRegions.firstIndex(where: isEqual) == .none
            }
            
            func notContainedByNativeRegions(predicate: Region) -> Bool {
                func isEqual(nativeRegion: R.NativeRegion) -> Bool {
                    nativeRegion.isEqual(to: predicate)
                }
                return nativeRegions.firstIndex(where: isEqual) == .none
            }

            var regionsSubtractingNativeRegions: [Region] {
                predicateRegions.filter(notContainedByNativeRegions)
            }

            var nativeRegionsSubtractingRegions: [R.NativeRegion] {
                nativeRegions.filter(notContainedByRegions)
            }

            switch diffing {
                case .set: return (
                    added: Array(predicateRegions),
                    removed: nativeRegionsSubtractingRegions
                )
                case .update: return (
                    added: regionsSubtractingNativeRegions,
                    removed: nativeRegionsSubtractingRegions
                )
            }
        }

        
        var synchronizeRegions: AnyPublisher<Void, Error> {
            let (addedRegions, removedRegions) = regionsDifference

            regions.remove(regions: removedRegions)
            return regions.add(regions: addedRegions)
        }

        
        return positionChangePublishers
            .setFailureType(to: Error.self)
            .combineLatest(synchronizeRegions)
            .map(\.0)
            .eraseToAnyPublisher()
    }
}
