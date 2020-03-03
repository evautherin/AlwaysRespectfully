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
    
    func add(predicates: Set<NativePredicate>) -> AnyPublisher<Void, Error>
    func remove(predicateIdentifiers: [String])
    func mask(predicateIdentifiers: [String])
    func unmask(predicateIdentifiers: [String])
}
