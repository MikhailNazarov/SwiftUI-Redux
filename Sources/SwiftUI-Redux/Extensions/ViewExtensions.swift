//
//  ViewExtensions.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 09.01.2021.
//

import SwiftUI

extension View{
    public func eraseToAnyView()-> AnyView{
        AnyView(self)
    }
}
