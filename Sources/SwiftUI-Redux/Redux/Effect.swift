//
//  Effect.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 09.01.2021.
//

import Combine

public enum Effect<State, Action>{
    case none
    case state(_ state: State)
    case action(_ action: Action)
    case actions(_ actions: AnyPublisher<Action,Never>)
    
    case stateWithAction(state: State, action: Action)
    case stateWithActions(state: State, actions: AnyPublisher<Action, Never>)
}

public extension AnyPublisher{
    func asEffect<State>()-> Effect<State, Output> where Failure == Never{
        return Effect.actions(self)
    }
    
    func asEffect<State>(state: State)-> Effect<State, Output> where Failure == Never{
        return Effect.stateWithActions(state: state, actions: self)
    }
}

public extension Publisher{
    func asEffect<State>()-> Effect<State, Output> where Failure == Never{
        return self.eraseToAnyPublisher().asEffect()
    }
    
    func asEffect<State>(state: State)-> Effect<State, Output> where Failure == Never{
        return self.eraseToAnyPublisher().asEffect(state: state)
    }
}
