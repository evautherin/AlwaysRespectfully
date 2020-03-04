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
    
    var insideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
    var outsideRegionPublisher: AnyPublisher<NativeRegion, Never>  { get }
    // Publishers.Merge(delegate.didEnterRegionSubject, delegate.insideRegionSubject)
}


protocol RegionEquatable {
    func isEqual<L>(to: Region<L>) -> Bool where L: Location
}


extension RegionStore {
    static func notContainedBy<L>(
        _ regions: Set<Region<L>>
    ) -> (NativeRegion) -> Bool
        where L: Location, L: Hashable, NativeRegion: RegionEquatable {
        
        return { (nativeRegion) -> Bool in
            func isEqual(region: Region<L>) -> Bool {
                nativeRegion.isEqual(to: region)
            }
                
            return regions.firstIndex(where: isEqual) == .none
        }
    }

    static func notContainedBy<L>(
        _ nativeRegions: Set<NativeRegion>
    ) -> (Region<L>) -> Bool
        where L: Location, L: Hashable, NativeRegion: RegionEquatable {
        
        return { (region) -> Bool in
            func isEqual(nativeRegion: NativeRegion) -> Bool {
                nativeRegion.isEqual(to: region)
            }
                
            return nativeRegions.firstIndex(where: isEqual) == .none
        }
    }
}


extension Collection {
    func subtracting<R, L>(
        _ store: R,
        nativeRegions: Set<R.NativeRegion>
    ) -> [Region<L>]
        where Element == Region<L>, L: Location,
        R: RegionStore, R.NativeRegion: RegionEquatable {
            
            let notInNativeRegions: (Element) -> Bool = R.notContainedBy(nativeRegions)
            return filter(notInNativeRegions)
    }
    
    func subtracting<R, L>(
        _ store: R,
        regions: Set<Region<L>>
    ) -> [Element]
        where Element == R.NativeRegion, R.NativeRegion: RegionEquatable,
        L: Location, L: Hashable, R: RegionStore {
            
            let notInRegions: (Element) -> Bool = R.notContainedBy(regions)
            return filter(notInRegions)
    }
}


