//
//  Reducer.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 05.12.2020.
//

import Foundation
import Combine

public struct Reducer<State, Action, Environment> {
    public let reduce: (State, Action, Environment) -> Effect<State, Action>
    
    public func callAsFunction(
        _ state: State,
        _ action: Action,
        _ environment: Environment
    ) -> Effect<State, Action> {
        reduce(state, action, environment)
    }
    
    public init(reduce: @escaping (State, Action, Environment) -> Effect<State, Action>){
        self.reduce = reduce
    }
    
//    func indexed<IndexedState, IndexedAction, IndexedEnvironment, Key>(
//        keyPath: WritableKeyPath<IndexedState, [Key: State]>,
//        prism: Prism<IndexedAction, (Key, Action)>,
//        extractEnvironment: @escaping (IndexedEnvironment) -> Environment
//    ) -> Reducer<IndexedState, IndexedAction, IndexedEnvironment> {
//        .init { state, action, environment in
//            guard let (index, action) = prism.extract(action) else {
//                return Empty().eraseToAnyPublisher()
//            }
//            let environment = extractEnvironment(environment)
//            return self
//                .optional()
//                .reduce(&state[keyPath: keyPath][index], action, environment)
//                .map { prism.embed((index, $0)) }
//                .eraseToAnyPublisher()
//        }
//    }
    
//    func indexed<IndexedState, IndexedAction, IndexedEnvironment>(
//        keyPath: WritableKeyPath<IndexedState, [State]>,
//        prism: Prism<IndexedAction, (Int, Action)>,
//        extractEnvironment: @escaping (IndexedEnvironment) -> Environment
//    ) -> Reducer<IndexedState, IndexedAction, IndexedEnvironment> {
//        .init { state, action, environment in
//            guard let (index, action) = prism.extract(action) else {
//                return Empty().eraseToAnyPublisher()
//            }
//            let environment = extractEnvironment(environment)
//            return self
//                .reduce(&state[keyPath: keyPath][index], action, environment)
//                .map { prism.embed((index, $0)) }
//                .eraseToAnyPublisher()
//        }
//    }
//
//    func optional() -> Reducer<State?, Action, Environment> {
//        .init { state, action, environment in
//            if state != nil {
//                return self(&state!, action, environment)
//            } else {
//                return Empty(completeImmediately: true).eraseToAnyPublisher()
//            }
//        }
//    }
    
//    func lift<LiftedState, LiftedAction, LiftedEnvironment>(
//        keyPath: WritableKeyPath<LiftedState, State>,
//        prism: Prism<LiftedAction, Action>,
//        extractEnvironment: @escaping (LiftedEnvironment) -> Environment
//    ) -> Reducer<LiftedState, LiftedAction, LiftedEnvironment> {
//        .init { state, action, environment in
//            let environment = extractEnvironment(environment)
//            guard let action = prism.extract(action) else {
//                return Empty(completeImmediately: true).eraseToAnyPublisher()
//            }
//            let effect = self(&state[keyPath: keyPath], action, environment)
//            return effect.map(prism.embed).eraseToAnyPublisher()
//        }
//    }
//    
//    static func combine(_ reducers: Reducer...) -> Reducer {
//        .init { state, action, environment in
//            let effects = reducers.compactMap { $0(&state, action, environment) }
//            return Publishers.MergeMany(effects).eraseToAnyPublisher()
//        }
//    }
}
