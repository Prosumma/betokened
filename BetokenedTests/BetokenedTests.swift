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
    case Literal(String, Range<String.Index>)
    case Op(Character, Range<String.Index>)
    var debugDescription: String {
        switch self {
        case .Literal(let s): return "Literal \(s)"
        case .Op(let c): return "Operator \(c)"
        }
    }
    
    static func toLiteral(string: String, range: Range<String.Index>) -> Token {
        return .Literal(string, range)
    }
    
    static func toOp(string: String, range: Range<String.Index>) -> Token {
        return .Op(Character(string), range)
    }
}

func == (lhs: Token, rhs: Token) -> Bool {
    switch lhs {
    case .Literal(let ls, _):
        switch rhs {
        case .Literal(let rs, _): return ls == rs
        default: false
        }
    case .Op(let lop, _):
        switch rhs {
        case .Op(let rop, _): return lop == rop
        default: false
        }
    }
    return false
}

let TokenMatchFailed = "Token match failed."

class BetokenedTests: XCTestCase {
    
    func testString() {
        let test = "  betokened+"
        let s = string("betokened") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | s | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case let .Ok(tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, "betokened", TokenMatchFailed)
                XCTAssertEqual(test.substringWithRange(range), "betokened", TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }                
            default:
                XCTFail(TokenMatchFailed)
            }
        default:
            XCTFail(TokenMatchFailed)
        }
    }
    
    func testNonFinalAsymmetricDelimiterWithoutEscape() {
        let test = "{betokened}+"
        let braces = delimit("{", "}") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | braces | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betokened"
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("{betokened}", test.substringWithRange(range), TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testFinalAsymmetricDelimiterWithoutEscape() {
        let test = "+{betokened}"
        let braces = delimit("{", "}") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | braces | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betokened"
            switch tokens[1] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("{betokened}", test.substringWithRange(range), TokenMatchFailed)
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }
    
    func testNonFinalAsymmetricDelimiterWithEscape() {
        let test = "{betoke^}ned}+"
        let braces = delimit("{", "}", escape: "^") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | braces | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betoke}ned"
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("{betoke^}ned}", test.substringWithRange(range), TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }
    
    func testFinalAsymmetricDelimiterWithEscape() {
        let test = "+{betoke^}ned}"
        let braces = delimit("{", "}", escape: "^") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | braces | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betoke}ned"
            switch tokens[1] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("{betoke^}ned}", test.substringWithRange(range), TokenMatchFailed)
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }
    
    func testNonFinalSymmetricDelimiterWithoutEscape() {
        let test = "'betokened'+"
        let quotes = quote("'") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betokened"
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'betokened'", test.substringWithRange(range), TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testFinalSymmetricDelimiterWithoutEscape() {
        let test = "+'betokened'"
        let quotes = quote("'") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betokened"
            switch tokens[1] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'betokened'", test.substringWithRange(range), TokenMatchFailed)
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testNonFinalSymmetricDelimiterWithAsymmetricEscape() {
        let test = "'betoke^'ned'+"
        let quotes = quote("'", escape: "^") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betoke'ned"
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'betoke^'ned'", test.substringWithRange(range), TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testFinalSymmetricDelimiterWithAsymmetricEscape() {
        let test = "+'be^toke^'ned'"
        let quotes = quote("'", escape: "^") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "be^toke'ned"
            switch tokens[1] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'be^toke^'ned'", test.substringWithRange(range), TokenMatchFailed)
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testNonFinalSymmetricDelimiterWithSymmetricEscape() {
        let test = "'betoke''ned'+"
        let quotes = quote("'", escape: "'") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betoke'ned"
            switch tokens[0] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'betoke''ned'", test.substringWithRange(range), TokenMatchFailed)
                switch tokens[1] {
                case let .Op(c, range):
                    XCTAssertEqual(c, Character("+"), TokenMatchFailed)
                    XCTAssertEqual("+", test.substringWithRange(range), TokenMatchFailed)
                default:
                    XCTFail(TokenMatchFailed)
                }
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }

    func testFinalSymmetricDelimiterWithSymmetricEscape() {
        let test = "+'betoke''ned'"
        let quotes = quote("'", escape: "'") >> Token.toLiteral
        let op = string("+") >> Token.toOp
        let tokenizer = whitespace | quotes | op | end
        switch tokenizer.tokenize(StringStream(test)) {
        case .Ok(let tokens):
            XCTAssertEqual(tokens.count, 2, TokenMatchFailed)
            let betokened = "betoke'ned"
            switch tokens[1] {
            case let .Literal(string, range):
                XCTAssertEqual(string, betokened, TokenMatchFailed)
                XCTAssertEqual("'betoke''ned'", test.substringWithRange(range), TokenMatchFailed)
            default:
                XCTFail(TokenMatchFailed)
            }
        case .Err(let error):
            XCTFail("")
        }
    }
}
