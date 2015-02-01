//
//  BetokenedTests.swift
//  BetokenedTests
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import UIKit
import XCTest
import Swift

enum Token: DebugPrintable, Equatable {
    case Literal(String)
    case Op(Character)
    var debugDescription: String {
        switch self {
        case .Literal(let s): return "Literal \(s)"
        case .Op(let c): return "Operator \(c)"
        }
    }
}

func == (lhs: Token, rhs: Token) -> Bool {
    switch lhs {
    case .Literal(let ls):
        switch rhs {
        case .Literal(let rs): return ls == rs
        default: false
        }
    case .Op(let lop):
        switch rhs {
        case .Op(let rop): return lop == rop
        default: false
        }
    }
    return false
}

let TokenMatchFailed = "Token match failed."

class BetokenedTests: XCTestCase {
    
    func testDelimitCurlyBracesWithoutEscape() {
        let braces = delimit("{", "}", escape: nil) >> { string, _ in Token.Literal(string) }
        let parens = oneCharOf("()") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | parens | braces | end
        switch tokenizer.tokenize("(   {betokened}    )") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens[1], Token.Literal("betokened"), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }
    
    /*
    func testDelimitCurlyBracesWithEscape() {
        let braces = delimit("{", "}", escape: "^") >> { string, _ in Token.Literal(string) }
        let parens = oneCharOf("()") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | parens | braces | end
        switch tokenizer.tokenize("(   {be^^toke^}ned}    )") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens[1], Token.Literal("be^^toke}ned"), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }
    */
    
    func testQuotesWithoutEscape() {
        let quotes = quote("'", escape: nil) >> { string, _ in Token.Literal(string) }
        let tokenizer = whitespace | quotes | end
        switch tokenizer.tokenize(" 'betokened'") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens[0], Token.Literal("betokened"), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }
    
    func testString() {
        let s = string("betokened") >> { string, _ in Token.Literal(string) }
        let op = oneCharOf("(+)") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | op | s
        switch tokenizer.tokenize("( betokened)") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens[1], Token.Literal("betokened"), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }
    
    func testOneCharOf() {
        let op = oneCharOf("(+)") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | op
        switch tokenizer.tokenize("  (") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.first!, Token.Op("("), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }

    func testRegex() {
        let r = regex("[^\\s+()]+") >> { string, _ in Token.Literal(string) }
        let op = oneCharOf("(+)") >> { string, _ in Token.Op(Character(string)) }
        let tokenizer = whitespace | op | r | end
        switch tokenizer.tokenize("( betokened)   ") {
        case .Ok(let tokens):
            XCTAssertEqual(tokens[1], Token.Literal("betokened"), TokenMatchFailed)
            println(tokens)
        case .Err(let error): XCTFail(TokenMatchFailed)
        }
    }
}
