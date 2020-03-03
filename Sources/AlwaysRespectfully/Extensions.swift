//
//  Extensions.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 06/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Foundation
import Combine


#if swift(<5.2)
extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map({ $0[keyPath: keyPath] })
    }
    
    func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        return compactMap({ $0[keyPath: keyPath] })
    }
}
#endif


extension Publishers {
    static func zipMany(_ publishers: [AnyPublisher<(), Error>]) -> AnyPublisher<(), Error> {
        
        func zipper(zipped: AnyPublisher<(), Error>, toZip: AnyPublisher<(), Error>) -> AnyPublisher<(), Error> {
            Publishers.Zip(zipped, toZip)
                .map({ _ in })
                .eraseToAnyPublisher()
        }
        
        let neutralElement = Just<Void>(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        return publishers.reduce(neutralElement, zipper)
        .eraseToAnyPublisher()
    }
}


