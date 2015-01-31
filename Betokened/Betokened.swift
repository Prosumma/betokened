//
//  Betokened.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Swift

public final class Cell<T> {
    public let contents: T
    public init(contents: T) {
        self.contents = contents
    }
}

prefix operator * {}

public prefix func *<T>(cell: Cell<T>) -> T {
    return cell.contents
}

postfix operator * {}

public postfix func *<T>(contents: T) -> Cell<T> {
    return Cell(contents: contents)
}

public enum Error {
    case UnterminatedDelimiter(String.Index)
    case EndOfStringExpected(String.Index)
}

public enum ParserResult {
    case Ok(String, Range<String.Index>)
    case Err(Error)
}

public enum RecognizerResult<T> {
    case Ok(Cell<T>?)
    case Err(Error)
}

public enum TokenizerResult<T> {
    case Ok([T])
    case Err(Error)
}

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

public final class Tokenizer<T> {
    typealias Recognizer = StringStream -> RecognizerResult<T>?
    private let recognizers: [Recognizer]
    public init(_ recognizers: [Recognizer]) {
        self.recognizers = recognizers
    }
    public convenience init(_ recognizers: Recognizer...) {
        self.init(recognizers)
    }
    public func tokenize(stream: StringStream) -> TokenizerResult<T> {
        var tokenizerResult: TokenizerResult<T>?
        var tokens = [T]()
        tokenizing: while !stream.atEnd {
            var recognized = false
            for recognize in recognizers {
                if let recognizerResult = recognize(stream) {
                    switch recognizerResult {
                    case .Ok(let cell):
                        if let cell = cell { tokens.append(*cell) }
                        continue tokenizing
                    case .Err(let error):
                        tokenizerResult = .Err(error)
                        break tokenizing
                    }
                }
            }
            if !recognized { break }
        }
        return tokenizerResult ?? .Ok(tokens)
    }
}

public func transform<T>(parseResult: ParserResult?, tokenize: (String, Range<String.Index>) -> T)(stream: StringStream) -> RecognizerResult<T>? {
    var recognizerResult: RecognizerResult<T>?
    if let parseResult = parseResult {
        switch parseResult {
        case let .Ok(string, range):
            recognizerResult = .Ok(tokenize(string, range)*)
        case let .Err(error):
            recognizerResult = .Err(error)
        }
    }
    return recognizerResult
}

public func transform<T>(parse: StringStream -> ParserResult?, tokenize: (String, Range<String.Index>) -> T)(stream: StringStream) -> RecognizerResult<T>? {
    return transform(parse(stream), tokenize)(stream: stream)
}

public func >> <T>(parseResult: ParserResult?, tokenize: (String, Range<String.Index>) -> T)(stream: StringStream) -> RecognizerResult<T>? {
    return transform(parseResult, tokenize)(stream: stream)
}

public func >> <T>(parse: StringStream -> ParserResult?, tokenize: (String, Range<String.Index>) -> T)(stream: StringStream) -> RecognizerResult<T>? {
    return transform(parse, tokenize)(stream: stream)
}

public func combine<T>(lrecognizer: StringStream -> RecognizerResult<T>?, rrecognizer: StringStream -> RecognizerResult<T>?) -> Tokenizer<T> {
    return Tokenizer<T>(lrecognizer, rrecognizer)
}

public func combine<T>(ltokenizer: Tokenizer<T>, rtokenizer: Tokenizer<T>) -> Tokenizer<T> {
    return Tokenizer<T>(ltokenizer.recognizers + rtokenizer.recognizers)
}

public func combine<T>(recognizer: StringStream -> RecognizerResult<T>?, tokenizer: Tokenizer<T>) -> Tokenizer<T> {
    return combine(Tokenizer<T>(recognizer), tokenizer)
}

public func combine<T>(tokenizer: Tokenizer<T>, recognizer: StringStream -> RecognizerResult<T>?) -> Tokenizer<T> {
    return combine(tokenizer, Tokenizer<T>(recognizer))
}

public func | <T>(lrecognizer: StringStream -> RecognizerResult<T>?, rrecognizer: StringStream -> RecognizerResult<T>?) -> Tokenizer<T> {
    return combine(lrecognizer, rrecognizer)
}

public func | <T>(ltokenizer: Tokenizer<T>, rtokenizer: Tokenizer<T>) -> Tokenizer<T> {
    return combine(ltokenizer, rtokenizer)
}

public func | <T>(recognizer: StringStream -> RecognizerResult<T>?, tokenizer: Tokenizer<T>) -> Tokenizer<T> {
    return combine(recognizer, tokenizer)
}

public func | <T>(tokenizer: Tokenizer<T>, recognizer: StringStream -> RecognizerResult<T>?) -> Tokenizer<T> {
    return combine(tokenizer, recognizer)
}

public func whitespace(stream: StringStream) -> ParserResult? {
    var parserResult: ParserResult?
    let whitespaceAndNewLineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let startIndex = stream.index
    while !stream.atEnd {
        let string = stream.string
        if let range = string.rangeOfCharacterFromSet(whitespaceAndNewLineCharacterSet, options: nil, range: string.startIndex..<string.endIndex) {
            if range.startIndex == string.startIndex {
                parserResult = .Ok("", startIndex..<stream.index)
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

public func whitespace<T>(stream: StringStream) -> RecognizerResult<T>? {
    var recognizerResult: RecognizerResult<T>?
    if let parserResult: ParserResult = whitespace(stream) {
        switch parserResult {
        case .Ok(_, _):
            recognizerResult = .Ok(nil)
        case .Err(let error):
            recognizerResult = .Err(error)
        }
    }
    return recognizerResult
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

public func end<T>(stream: StringStream) -> RecognizerResult<T>? {
    return stream.atEnd ? .Ok(nil) : .Err(.EndOfStringExpected(stream.index))
}

