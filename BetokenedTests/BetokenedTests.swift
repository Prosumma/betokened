//
//  BetokenedTests.swift
//  BetokenedTests
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import UIKit
import XCTest

enum Token: DebugPrintable {
    case Literal(String)
    case Op(Character)
    var debugDescription: String {
        switch self {
        case .Literal(let s): return "Literal '\(s)'"
        case .Op(let c): return "Operator \(c)"
        }
    }
}

class BetokenedTests: XCTestCase {
    
    func testOneCharOf() {
        let op = oneCharOf("(+)") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | op
        switch tokenizer.tokenize("  (") {
        case .Ok(let tokens): println(tokens)
        case .Err(let error): println(error)
        }
    }
    
}
