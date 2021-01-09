//
//  Prism.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 05.12.2020.
//

import Foundation

public struct Prism<Source, Target> {
    let embed: (Target) -> Source
    let extract: (Source) -> Target?
}
