//
//  StringStream.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation

public class StringStream: StringLiteralConvertible {
    private var storage: String
    public var index: String.Index
    public required init(_ string: String) {
        storage = string
        index = storage.startIndex
    }
    public required convenience init(stringLiteral value: String) {
        self.init(value)
    }
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    public var string: String {
        return storage.substringFromIndex(index)
    }
    public var atEnd: Bool {
        return index == storage.endIndex
    }
    public func convert(range: Range<String.Index>) -> Range<String.Index> {
        let d = distance(range.startIndex, range.endIndex)
        return index..<advance(index, d)
    }
    public func convert(distance: String.Index.Distance) -> Range<String.Index> {
        return index..<advance(index, distance)
    }
}
