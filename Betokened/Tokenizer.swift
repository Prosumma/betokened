//
//  Tokenizer.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

public final class Tokenizer<T> {
    typealias Recognizer = StringStream -> RecognizerResult<T>?
    public let recognizers: [Recognizer]
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