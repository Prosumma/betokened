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
    let whitespaceAndNewLineCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
    let startIndex = stream.index
    while !stream.atEnd {
        let string = stream.string
        if let range = string.rangeOfCharacterFromSet(whitespaceAndNewLineCharacterSet, options: nil, range: string.startIndex..<string.endIndex) {
            if range.startIndex == string.startIndex {
                recognizerResult = .Ok(nil)
                stream.index = advance(stream.index, 1)
            } else {
                break
            }
        } else {
            break
        }
    }
    return recognizerResult
}

public func end<T>(stream: StringStream) -> RecognizerResult<T>? {
    return stream.atEnd ? .Ok(nil) : .Err(.EndOfStringExpected(stream.index))
}
