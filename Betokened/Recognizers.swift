//
//  Recognizers.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

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

public func end<T>(stream: StringStream) -> RecognizerResult<T>? {
    return stream.atEnd ? .Ok(nil) : .Err(.EndOfStringExpected(stream.index))
}
