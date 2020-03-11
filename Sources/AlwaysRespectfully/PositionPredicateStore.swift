//
//  PositionPredicateStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol PositionPredicateStore {
    associatedtype NativePredicate: Hashable, Identifiable
    
    var storedPredicates: Future<Set<NativePredicate>, Never> { get }

    func add<P>(predicates: [P]) -> AnyPublisher<Void, Error> where P: PositionPredicate
    func remove(predicateIdentifiers: [NativePredicate.ID])
    
    func mask(predicateIdentifiers: [String])
    func unmask(predicateIdentifiers: [String])
}


public protocol PredicateEquatable {
    func isEqual<P>(to: P) -> Bool where P: PositionPredicate
}
