//
//  RegionStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol RegionStore {
    associatedtype NativeRegion: Hashable, RegionEquatable

    var storedRegions: Set<NativeRegion> { get }
    
    func add(regions: [Region]) -> AnyPublisher<Void, Error>
    func remove(regions: [NativeRegion])
    
    var insideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
    var outsideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
}


public protocol RegionEquatable {
    func isEqual(to: Region) -> Bool
}
