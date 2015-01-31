//
//  BetokenedTests.swift
//  BetokenedTests
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import UIKit
import XCTest

enum Token {
    case Literal(String, Range<String.Index>)
}

class BetokenedTests: XCTestCase {

    func testWatusi() {
        let gregory = string("gregory") >> { string, range in Token.Literal(string, range) }
        let tokenizer = whitespace | gregory | end
        switch tokenizer.tokenize("   gregory  ") {
        case .Ok(let tokens):
            for token in tokens {
                switch token {
                case let .Literal(string, _):
                    println(string)
                }
            }
        case .Err(let error):
            println(error)
        }
    }
    
}
