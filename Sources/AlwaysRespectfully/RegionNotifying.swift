//
//  RegionNotifying.swift
//  AlwaysRespectful
//
//  Created by Etienne Vautherin on 18/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
import UserNotifications


extension AlwaysRespectfully {
    func setNotifications(
        _ diffing: Diffing,
        predicates: Set<Predicate>
    ) -> AnyPublisher<Void, Error> {
        
        Empty<Void, Error>().setFailureType(Error.self).eraseToAnyPublisher()
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
