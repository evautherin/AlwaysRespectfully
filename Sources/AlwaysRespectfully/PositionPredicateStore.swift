//
//  PositionPredicateStore.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 02/03/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


public protocol PositionPredicateStore {
    associatedtype NativePredicate: Hashable, PositionPredicate, PredicateEquatable
    
    var storedPredicates: Future<Set<NativePredicate>, Never> { get }

    func add<Predicate>(predicates: [Predicate]) -> AnyPublisher<Void, Error> where Predicate: PositionPredicate
    
//    func add(predicate: AnyPositionPredicate) -> Future<Void, Error>? {
//        guard let request = predicate.notificationRequest else { return .none }
//
//        return NotificationDelegate.add(request: request) //.eraseToAnyPublisher()
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
