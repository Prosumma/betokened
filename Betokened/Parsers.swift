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
                    stream.index = streamRange.endIndex
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

public func regex(pattern: String)(stream: StringStream) -> ParserResult? {
    return {
        var parserResult: ParserResult?
        var error = NSErrorPointer()
        let string = stream.string
        if let range = string.rangeOfString(pattern, options: .RegularExpressionSearch, range: string.startIndex..<string.endIndex, locale: nil) {
            if range.startIndex == string.startIndex {
                let streamRange = stream.convert(range)
                parserResult = .Ok(string.substringWithRange(range), streamRange)
                stream.index = streamRange.endIndex
            }
        }
        return parserResult
    }()
}

public func delimit(start: Character, end: Character, escape: Character? = nil)(stream: StringStream) -> ParserResult? {
    return {
        var parserResult: ParserResult?
        let string = stream.string
        let startIndex = string.startIndex
        if let c = first(string) {
            if start == c {
                var parsed = ""
                var escaping = false
                var index = startIndex
                while true {
                    index = advance(index, 1)
                    if index == string.endIndex {
                        if escaping && end == escape {
                            let streamRange = stream.convert(startIndex..<index)
                            parserResult = .Ok(parsed, streamRange)
                            stream.index = streamRange.endIndex
                            break
                        } else {
                            parserResult = .Err(Error.UnterminatedDelimiter(stream.index))
                            break
                        }
                    }
                    var c = string[index]
                    if escaping {
                        if c == end {
                            parsed.append(c)
                        } else if end == escape {
                            let streamRange = stream.convert(startIndex..<index)
                            parserResult = .Ok(parsed, streamRange)
                            stream.index = streamRange.endIndex
                            break
                        } else {
                            parsed.append(escape!)
                            parsed.append(c)
                        }
                        escaping = false
                    } else if c == escape {
                        escaping = true
                    } else if c == end {
                        let streamRange = stream.convert(startIndex...index)
                        parserResult = .Ok(parsed, streamRange)
                        stream.index = streamRange.endIndex
                        break
                    } else {
                        parsed.append(c)
                    }
                }
            }
        }
        return parserResult
    }()
}

public func quote(mark: Character, escape: Character? = nil)(stream: StringStream) -> ParserResult? {
    return delimit(mark, mark, escape: escape)(stream: stream)
}
