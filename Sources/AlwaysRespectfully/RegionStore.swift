//
//  RegionStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//


protocol RegionStore {
    associatedtype NativeRegion: Region

    public var storedRegions: Set<NativeRegion> { get }
    
    public func add(regions: Set<NativeRegion>) -> AnyPublisher<Void, Error>
    public func remove(regions: Set<NativeRegion>)
}
