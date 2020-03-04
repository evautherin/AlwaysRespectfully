//
//  RegionStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol RegionStore {
    associatedtype L: Location, Hashable
    associatedtype NativeRegion: Hashable, RegionEquatable

    var storedRegions: Set<NativeRegion> { get }
    
    func add<Predicate>(regions: [Region<Predicate.L>], _: Predicate.Type) -> AnyPublisher<Void, Error> where Predicate: PositionPredicate
    func remove(regions: [NativeRegion])
    
    var insideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
    var outsideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
    // Publishers.Merge(delegate.didEnterRegionSubject, delegate.insideRegionSubject)
}


public protocol RegionEquatable {
    func isEqual<L>(to: Region<L>) -> Bool where L: Location
}
