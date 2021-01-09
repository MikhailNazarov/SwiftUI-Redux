//
//  Store.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 05.12.2020.
//

import Foundation
import Combine
import SwiftUI



public final class Store<State, Action>: ObservableObject {
    
    @Published public private(set) var state: State
    
    private let reduce: (State, Action) -> Effect<State, Action>
    private var effectCancellables: [UUID: AnyCancellable] = [:]
    private var derivedCancellables = CancelBag()
    private let queue: DispatchQueue
    
    public init<Environment>(initialState: State,
                      reducer: Reducer<State, Action, Environment>,
                      environment: Environment,
                      subscriptionQueue: DispatchQueue = .init(label: "redux.store")
    ){
        self.queue = subscriptionQueue
        self.state = initialState
        self.reduce = { state, action in
            reducer(state, action, environment)
        }
        
    }
    
    public func send(_ action: Action) {
        let effect = reduce(state, action)
        
        var publisher: AnyPublisher<Action, Never>? = nil
        switch effect{
        
        case .none:
            break
        case .state(_: let state):
            self.state = state
            break
        case .action(_: let action):
            self.send(action)
            break
        case .actions(_: let actions):
            publisher = actions
            break
        case .stateWithAction(state: let state, action: let action):
            self.state = state
            self.send(action)
        case .stateWithActions(state: let state, actions: let actions):
            self.state = state
            publisher = actions
            break
        }
        
        guard let pub = publisher else {
            return
        }
        var didComplete = false
        let uuid = UUID()
        
        let cancellable = pub
            .subscribe(on: queue)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    self?.effectCancellables[uuid] = nil
                },
                receiveValue: { [weak self] in self?.send($0) }
            )
        
        if !didComplete {
            effectCancellables[uuid] = cancellable
        }
    }
    
    
//    func derived<: Equatable, ExtractedAction>(
//        deriveState: @escaping (State) -> DerivedState,
//        embedAction: @escaping (ExtractedAction) -> Action
//    ) -> Store<DerivedState, ExtractedAction> {
//        let store = Store<DerivedState, ExtractedAction>(
//            initialState: deriveState(state),
//            reducer: Reducer { _, action, _ in
//                self.send(embedAction(action))
//                return Effect<DerivedState, ExtractedAction>.none
//            },
//            environment: ()
//        )
//        
//        let statePublisher = $state
//            .subscribe(on: store.queue)
//            .map(deriveState)
//            .removeDuplicates()
//            .receive(on: DispatchQueue.main)
//        
//        if #available(iOS 14, macOS 11, *){
//            statePublisher.assign(to: &store.$state)
//        } else{
//            statePublisher.sink{
//                state in
//                store.state = state
//            }.store(in: derivedCancellables)
//        }
//        
//        return store
//    }
}

public extension Store {
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        toAction: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(toAction($0)) }
        )
    }
}
