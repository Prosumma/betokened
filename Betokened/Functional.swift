//
//  Functional.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

public func transform<T>(parseResult: ParserResult?, tokenize: (String, Range<String.Index>) -> T)(stream: StringStream) -> RecognizerResult<T>? {
    var recognizerResult: RecognizerResult<T>?
    if let parseResult = parseResult {
        switch parseResult {
        case let .Ok(string, range):
            if let string = string {
                recognizerResult = .Ok(tokenize(string, range)*)
            } else {
                recognizerResult = .Ok(nil)
            }
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
