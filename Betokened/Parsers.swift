//
//  Parsers.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

public func string(match: String)(stream: StringStream) -> ParserResult? {
    return {
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
    }()
}

public func oneCharOf(string: String)(stream: StringStream) -> ParserResult? {
    return {
        var parserResult: ParserResult?
        if let c = first(stream.string) {
            for ch in string {
                if c == ch {
                    parserResult = .Ok(String(c), stream.index..<advance(stream.index, 1))
                    stream.index = advance(stream.index, 1)
                    break
                }
            }
        }
        return parserResult
    }()
}

public func oneStringOf(strings: [String])(stream: StringStream) -> ParserResult? {
    return {
        var parserResult: ParserResult?
        for s in strings {
            parserResult = string(s)(stream: stream)
            if parserResult != nil { break }
        }
        return parserResult
    }()
}

public func oneStringOf(strings: String...)(stream: StringStream) -> ParserResult? {
    return { oneStringOf(strings)(stream: stream) }()
}

