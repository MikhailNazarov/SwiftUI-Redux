//
//  CombineExtensions.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 11.12.2020.
//

import Combine

extension Publisher{
    public func flatMap<T, P>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P) -> Publishers.FlatMap<P, Self> where T == P.Output, P : Publisher, Self.Failure == P.Failure{
        
        Publishers.FlatMap(upstream: self, maxPublishers: maxPublishers, transform: transform)
    }
}


