//
//  PositionPredicateStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol PositionPredicateStore {
    associatedtype Predicate: PositionPredicate
    associatedtype NativePredicate: Hashable, Identifiable, AbstractlyEquatable
    
    var storedPredicates: Future<Set<NativePredicate>, Never> { get }

    func add<Predicate>(predicates: [Predicate]) -> AnyPublisher<Void, Error> // where Predicate: PositionPredicate
    func remove(predicateIdentifiers: [NativePredicate.ID])
    
    func mask(predicateIdentifiers: [String])
    func unmask(predicateIdentifiers: [String])
}


//public protocol PredicateEquatable {
//    func isEqual<Predicate>(to: Predicate) -> Bool where Predicate: PositionPredicate
//}
