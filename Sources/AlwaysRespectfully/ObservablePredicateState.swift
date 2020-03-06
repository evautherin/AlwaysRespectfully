//
//  ObservableModel.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 06/03/2020.
//

import SwiftUI
import Combine


public class ObservablePredicateState: ObservableObject, Identifiable {
    public let id: String
    
    @Published public var state: PredicateState

    public enum Action {
        case setState(PredicateState)
    }
    public let actions = PassthroughSubject<Action, Never>()
    public var subscriptions = Set<AnyCancellable>()


    public init(id: String, initialState: PredicateState) {
        self.id = id
        self.state = initialState

        $state
            .removeDuplicates()
            .sink(receiveValue: stateDidChange)
            .store(in: &subscriptions)
        
        actions
            .sink(receiveValue: reducer)
            .store(in: &subscriptions)
    }


    public func sendAction(state: PredicateState) {
        actions.send(.setState(state))
    }


    var identicalState: Binding<Bool> {
        Binding(
            get: { self.state.isIdentical },
            set: { self.sendAction(state: PredicateState(isIdentical: $0)) }
        )
    }


    public func reducer(action: Action) {
        switch action {
        case .setState(let newState): state = newState
        }
    }
    
    
    public func stateDidChange(state: PredicateState) {}
}
