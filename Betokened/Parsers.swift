//
//  Parsers.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

public func whitespace(stream: StringStream) -> ParserResult? {
    var parserResult: ParserResult?
    let whitespaceAndNewLineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let startIndex = stream.index
    while !stream.atEnd {
        let string = stream.string
        if let range = string.rangeOfCharacterFromSet(whitespaceAndNewLineCharacterSet, options: nil, range: string.startIndex..<string.endIndex) {
            if range.startIndex == string.startIndex {
                parserResult = .Ok(nil, startIndex..<stream.index)
                stream.index = advance(stream.index, 1)
            } else {
                break
            }
        } else {
            break
        }
    }
    return parserResult
}

public func string(match: String)(stream: StringStream) -> ParserResult? {
    var parserResult: ParserResult?
    if !stream.atEnd {
        let string = stream.string
        if let range = string.rangeOfString(match, options: nil, range: string.startIndex..<string.endIndex, locale: nil) {
            if range.startIndex == string.startIndex {
                let streamRange = stream.convert(range)
                parserResult = .Ok(match, streamRange)
                stream.index = advance(streamRange.endIndex, 1)
            }
        }
    }
    return parserResult
}

