//
//  Stack.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 10.12.2020.
//

import Foundation

public struct Stack<T>{
    private var items: [T] = []
    
    public mutating func push(_ item: T){
        items.append(item)
    }
    
    public mutating func pop()->T?{
        guard hasItems() else {
            return nil
        }
        return items.removeLast()
    }
    
    public func hasItems()->Bool{
        items.count > 0
    }
    
    public init(){
        
    }
}
