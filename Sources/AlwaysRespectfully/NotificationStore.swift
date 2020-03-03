//
//  PositionPredicate.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

protocol PositionPredicateStore {
    associatedtype NativePredicate: PositionPredicate, Identifiable
    
    public var storedPredicates: Future<Set<NativePredicate>, Never> { get }
    
    public func add(predicates: Set<NativePredicate>) -> AnyPublisher<Void, Error>
    public func remove(predicateIdentifiers: [String])
    public func mask(predicateIdentifiers: [String])
    public func unmask(predicateIdentifiers: [String])
}
