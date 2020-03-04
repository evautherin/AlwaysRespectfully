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
    func monitorRegions<Predicate>(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<(Predicate, Direction), Error> where Predicate: PositionPredicate, Predicate: Hashable {

        func positionChangePublisher(predicate: Predicate) -> AnyPublisher<(Predicate, Direction), Never> {
                        
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

            func predicateDirection(position: Position) -> (Predicate, Direction) {
                (predicate, Direction.comparing(predicate.position, position))
            }
            
            return Publishers.Merge(inside, outside)
                .removeDuplicates()
                .map(predicateDirection)
                .logDebug(".positionChangePublisher")
        }
        let positionChangePublishers = Publishers.MergeMany(predicates.map(positionChangePublisher))
        
        
        var regionsDifference: (added: [Region<Predicate.L>], removed: [R.NativeRegion]) {
                
            let predicateRegions = predicates.map(\.region)
            let nativeRegions = regions.storedRegions

            func notContainedByRegions(nativeRegion: R.NativeRegion) -> Bool {
                func isEqual(predicate: Region<Predicate.L>) -> Bool {
                    nativeRegion.isEqual(to: predicate)
                }
                return predicateRegions.firstIndex(where: isEqual) == .none
            }
            
            func notContainedByNativeRegions(predicate: Region<Predicate.L>) -> Bool {
                func isEqual(nativeRegion: R.NativeRegion) -> Bool {
                    nativeRegion.isEqual(to: predicate)
                }
                return nativeRegions.firstIndex(where: isEqual) == .none
            }

            var regionsSubtractingNativeRegions: [Region<Predicate.L>] {
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

        
        var applyRegionChanges: AnyPublisher<Void, Error> {
            let (addedRegions, removedRegions) = regionsDifference

            regions.remove(regions: removedRegions)
            return regions.add(regions: addedRegions, Predicate.self)
        }

        
        return positionChangePublishers
            .setFailureType(to: Error.self)
            .combineLatest(applyRegionChanges)
            .map(\.0)
            .eraseToAnyPublisher()
    }
}
