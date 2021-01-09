//
//  Loadable.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 03.12.2020.
//

import Foundation
import SwiftUI


typealias LoadableSubject<Value> = Binding<Loadable<Value>>

public enum Loadable<T> {

    case notRequested
    case isLoading(T?)
    case loaded(T)
    case failed(Error)

    public var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last): return last
        default: return nil
        }
    }
    public var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
}


public extension Loadable {
    
    func isLoaded()->Bool{
        if case .loaded = self {
            return true
        }
        return false
    }
    func isLoadedOrLoading()->Bool{
        if case .loaded = self{
            return true
        }
        if  case .isLoading = self {
            return true
        }
        return false
    }
    
    
    func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
        do {
            switch self {
            case .notRequested: return .notRequested
            case let .failed(error): return .failed(error)
            case let .isLoading(value):
                return .isLoading(try value.map { try transform($0) })
            case let .loaded(value):
                return .loaded(try transform(value))
            }
        } catch {
            return .failed(error)
        }
    }
}

public protocol SomeOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

public struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}

extension Optional: SomeOptional {
    public func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none: throw ValueIsMissingError()
        }
    }
}

extension Loadable where T: SomeOptional {
    public func unwrap() -> Loadable<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension Loadable: Equatable where T: Equatable {
    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV), .isLoading(rhsV)): return lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}
