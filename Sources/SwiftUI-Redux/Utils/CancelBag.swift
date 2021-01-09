//
//  CancelBag.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 14.12.2020.
//

import Combine

public final class CancelBag {
    var subscriptions = Set<AnyCancellable>()
    
    func cancel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
}

public extension AnyCancellable {
    
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
