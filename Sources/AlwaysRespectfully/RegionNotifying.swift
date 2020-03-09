//
//  RegionNotifying.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 18/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


extension AlwaysRespectfully {
    func setNotifications(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<Void, Error> {

        var predicatesDifference: AnyPublisher<(added: [Predicate], removed: [N.NativePredicate]), Never> {
            
            func nativePredicatesDifference(
                nativePredicates: Set<N.NativePredicate>
            ) -> (added: [Predicate], removed: [N.NativePredicate]) {

                func notContainedByPredicates(nativePredicate: N.NativePredicate) -> Bool {
                    func isEqual(predicate: Predicate) -> Bool {
                        nativePredicate.isEqual(to: predicate)
                    }
                    return predicates.firstIndex(where: isEqual) == .none
                }
                
                func notContainedByNativePredicates(predicate: Predicate) -> Bool {
                    func isEqual(nativePredicate: N.NativePredicate) -> Bool {
                        nativePredicate.isEqual(to: predicate)
                    }
                    return nativePredicates.firstIndex(where: isEqual) == .none
                }

                var predicatesSubtractingNativePredicates: [Predicate] {
                    predicates.filter(notContainedByNativePredicates)
                }

                var nativePredicatesSubtractingPredicates: [N.NativePredicate] {
                    nativePredicates.filter(notContainedByPredicates)
                }

                switch diffing {
                    case .set: return (
                        added: Array(predicates),
                        removed: nativePredicatesSubtractingPredicates
                    )
                    case .update: return (
                        added: predicatesSubtractingNativePredicates,
                        removed: nativePredicatesSubtractingPredicates
                    )
                }
            }

            return notifications.storedPredicates
                .map(nativePredicatesDifference)
                .eraseToAnyPublisher()
        }

        
        func synchronize(
            addedPredicates: [Predicate],
            removedPredicates: [N.NativePredicate]
        ) -> AnyPublisher<Void, Error> {

            let removedIdentifiers = removedPredicates.map(\.id)
            notifications.remove(predicateIdentifiers: removedIdentifiers)
            return notifications.add(predicates: addedPredicates)
        }

        
        return predicatesDifference
            .setFailureType(to: Error.self)
            .flatMap(synchronize)
            .eraseToAnyPublisher()
    }

}


//struct RegionNotifying<Predicate> where Predicate: PositionPredicate, Predicate: Hashable {
//
//    static func predicatesDifference(
//        _ diffing: Diffing,
//        predicates: Set<Predicate>
//    ) -> AnyPublisher<(added: Set<AnyPositionPredicate>, removed: Set<AnyPositionPredicate>), Never> {
//
//        func requestsDifference(
//            requests: [UNNotificationRequest]
//        ) -> (added: Set<AnyPositionPredicate>, removed: Set<AnyPositionPredicate>) {
//
//            let target = Set(predicates.map(\.erasedToAnyPositionPredicate))
//            let current = Set(requests.compactMap(UNNotificationRequest.abstractPredicate))
//            let removed = current.subtracting(target)
//            switch diffing {
//                case .set: return (added: target, removed: removed)
//                case .update: return (added: target.subtracting(current), removed: removed)
//            }
//        }
//
//        return NotificationDelegate.pendingNotificationRequests
//            .map(requestsDifference)
//            .eraseToAnyPublisher()
//    }
//
//
//    static func setNotifications(
//        _ diffing: Diffing,
//        predicates: Set<Predicate>
//    ) -> AnyPublisher<Void, Error> {
//
//        func applyChanges(
//            addPredicates: Set<AnyPositionPredicate>,
//            removePredicates: Set<AnyPositionPredicate>
//        ) -> AnyPublisher<Void, Error> {
//
//            let removeIdentifiers = removePredicates.map(\.id)
//            NotificationDelegate.removePendingRequests(withIdentifiers: removeIdentifiers)
//
//            func add(predicate: AnyPositionPredicate) -> AnyPublisher<Void, Error>? {
//                guard let request = predicate.notificationRequest else { return .none }
//
//                return NotificationDelegate.add(request: request).eraseToAnyPublisher()
//            }
//
//            let publishers = addPredicates.compactMap(add)
//            return Publishers.zipMany(publishers)
//        }
//
//        return predicatesDifference(diffing, predicates: predicates)
//            .setFailureType(to: Error.self)
//            .flatMap(applyChanges)
//            .eraseToAnyPublisher()
//    }
//}
