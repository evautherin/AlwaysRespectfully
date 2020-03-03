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
    associatedtype NativeRegion: Hashable

    var storedRegions: Set<NativeRegion> { get }
    
    func add(regions: Set<NativeRegion>) -> AnyPublisher<Void, Error>
    func remove(regions: Set<NativeRegion>)
}
