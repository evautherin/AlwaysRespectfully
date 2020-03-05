//
//  Extensions.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 06/02/2020.
//  Copyright © 2020 Etienne Vautherin. All rights reserved.
//

import Combine


#if swift(<5.2)
extension Sequence {
    public func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map({ $0[keyPath: keyPath] })
    }
    
    public func compactMap<T>(_ keyPath: KeyPath<Element, T?>) -> [T] {
        return compactMap({ $0[keyPath: keyPath] })
    }
}
#endif


extension Publishers {
    public static func zipMany<VoidPublisher>(_ publishers: [VoidPublisher]) -> AnyPublisher<(), Error>
        where VoidPublisher: Publisher, VoidPublisher.Output == (), VoidPublisher.Failure == Error {
        
        func zipper(zipped: AnyPublisher<(), Error>, toZip: VoidPublisher) -> AnyPublisher<(), Error> {
            Publishers.Zip(zipped, toZip)
                .map({ _ in })
                .eraseToAnyPublisher()
        }
        
        let neutralElement = Just<()>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        return publishers.reduce(neutralElement, zipper)
            .eraseToAnyPublisher()
    }
}


