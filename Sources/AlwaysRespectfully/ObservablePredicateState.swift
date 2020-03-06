//
//  ObservableModel.swift
//  AlwaysRespectfully
//
//  Created by Etienne Vautherin on 06/03/2020.
//

import SwiftUI


public class ObservablePredicateState: ObservableObject, Identifiable {
    let id: String
    
    @Published public var state

    public enum Action {
        case set(state: PredicateState)
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
        actions.send(.set(state: state))
    }


    var identicalState: Binding<Bool> {
        Binding(
            get: { self.state.isIdentical },
            set: { self.sendAction(state: PredicateState(isIdentical: $0)) }
        )
    }


    public func reducer(action: Action) {
        switch action {
        case .setState(let state): self.state = state
        }
    }
    
    
    public func stateDidChange(state: PredicateState) {}
}
