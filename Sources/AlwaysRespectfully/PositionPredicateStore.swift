//
//  PositionPredicate.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol PositionPredicateStore {
    associatedtype NativePredicate: PositionPredicate, Hashable
    
    var storedPredicates: Future<Set<NativePredicate>, Never> { get }

    func add<Predicate>(predicates: [Predicate]) -> AnyPublisher<Void, Error>
        where Predicate: PositionPredicate
    
//    func add(predicate: AnyPositionPredicate) -> AnyPublisher<Void, Error>? {
//        guard let request = predicate.notificationRequest else { return .none }
//
//        return NotificationDelegate.add(request: request).eraseToAnyPublisher()
//    }
//
//    let publishers = addPredicates.compactMap(add)
//    return Publishers.zipMany(publishers)

    func remove(predicateIdentifiers: [String])
    func mask(predicateIdentifiers: [String])
    func unmask(predicateIdentifiers: [String])
}


public protocol PredicateEquatable {
    func isEqual<Predicate>(to: Predicate) -> Bool where Predicate: PositionPredicate
}


extension PositionPredicateStore {
    static func notContainedBy<Predicate>(
        _ predicates: Set<Predicate>
    ) -> (NativePredicate) -> Bool
        where Predicate: PositionPredicate, Predicate: Hashable, NativePredicate: PredicateEquatable {
        
        return { (nativePredicate) -> Bool in
            func isEqual(predicate: Predicate) -> Bool {
                nativePredicate.isEqual(to: predicate)
            }
                
            return predicates.firstIndex(where: isEqual) == .none
        }
    }

    static func notContainedBy<Predicate>(
        _ nativePredicates: Set<NativePredicate>
    ) -> (Predicate) -> Bool
        where Predicate: PositionPredicate, Predicate: Hashable, NativePredicate: PredicateEquatable {
        
        return { (predicate) -> Bool in
            func isEqual(nativePredicate: NativePredicate) -> Bool {
                nativePredicate.isEqual(to: predicate)
            }
                
            return nativePredicates.firstIndex(where: isEqual) == .none
        }
    }
}


extension Collection {
    func subtracting<N>(
        _ store: N,
        nativePredicates: Set<N.NativePredicate>
    ) -> [Element]
        where Element: PositionPredicate, Element: Hashable,
        N: PositionPredicateStore, N.NativePredicate: PredicateEquatable {
            
            let notInNativePredicates: (Element) -> Bool = N.notContainedBy(nativePredicates)
            return filter(notInNativePredicates)
    }
    
    func subtracting<N, Predicate>(
        _ store: N,
        predicates: Set<Predicate>
    ) -> [Element]
        where Element == N.NativePredicate, N.NativePredicate: PredicateEquatable,
        Predicate: PositionPredicate, Predicate: Hashable, N: PositionPredicateStore {
            
            let notInPredicates: (Element) -> Bool = N.notContainedBy(predicates)
            return filter(notInPredicates)
    }
}


// let a = LazyFilterCollection(_base: predicates, { _ in true } )

//extension LazyFilterCollection {
//    func subtracting<N>(
//        _ store: N,
//        nativePredicates: Set<N.NativePredicate>
//    ) -> LazyFilterSequence<Base>
//        where Base.Element: PositionPredicate, Base.Element: Hashable,
//        N: PositionPredicateStore, N.NativePredicate: PredicateEquatable {
//            
//            let notInNativePredicates: (Base.Element) -> Bool = N.notContainedBy(nativePredicates)
//            return filter(notInNativePredicates)
//    }
//
//    func subtracting<N, Predicate>(
//        _ store: N,
//        predicates: Set<Predicate>
//    ) -> LazyFilterSequence<Base>
//        where Base.Element == N.NativePredicate, N.NativePredicate: PredicateEquatable,
//        Predicate: PositionPredicate, Predicate: Hashable,
//        N: PositionPredicateStore {
//            
//            let notInPredicates: (Base.Element) -> Bool = N.notContainedBy(predicates)
//            return filter(notInPredicates)
//    }
//}
