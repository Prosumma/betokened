//
//  Types.swift
//  Betokened
//
//  Created by Gregory Higley on 1/31/15.
//  Copyright (c) 2015 Prosumma LLC. All rights reserved.
//

import Foundation
import Prosumma

public enum Error {
    case UnterminatedDelimiter(String.Index)
    case EndOfStringExpected(String.Index)
}

public enum ParserResult {
    case Ok(String?, Range<String.Index>)
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