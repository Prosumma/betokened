# Betokened

**Betokened** is a simple little Swift library that turns a string into an array of tokens. It has the following goals:

- It always tokenizes an underlying string.
- It is designed to be as simple and straightforward as possible.
- Custom operators are available to simplify syntax.
- I am using this in an iOS/OSX project I'm working on, so I'll be dogfooding it thoroughly. It will also have targets for each environment.

Betokened is *not* a parser combinator library. It creates a flat array of tokens that you are then responsible for turning into syntax. It does not understand hierarchy at all and never will. (My Parsimonious parser combinator library, which I never finished, will probably be repurposed to do that.)

## Example

    // Any type can be used as the token type, but an enum seems to work best.
    enum Token {
        case Literal(String)
    }

    // Sets up a Recognizer that matches the string "betokened" and if so, converts it to a Token.Literal.
    let betokened = string("betokened") >> { string, _ in Token.Literal(string) }

    // Set up a tokenizer that matches any one of these until the choices are exhausted
    // or we've exhausted the underlying string.
    let tokenizer = whitespace | betokened | end

    // Perform the tokenization and print the result
    switch tokenizer.tokenize("   betokened   ") {
        case .Ok(let tokens): println(tokens)
        case .Err(let error): println(error)
    }

## Recognizers

A Recognizer is a function that recognizes a portion of a string and converts it into a token. Recognizers have the following signature: `StringStream -> RecognizerResult<T>?`. Returning `nil` means that no match occurred. `RecognizerResult<T>` is an enumeration that contains either the result or an error. Here's an example of a trivial recognizer:

    // Match the string "betokened"
    func betokened(stream: StringStream) -> RecognizerResult<T>? {
        var result: RecognizerResult<T>?
        let string = stream.string
        if let range = string.rangeOfString("betokened", options: nil, range: string.startIndex..<string.endIndex, locale: nil) {
            if range.startIndex == string.startIndex {
                result = Token.Literal("betokened")
                // A recognizer is responsible for advancing the stream index if it recognizes.
                stream.index = advance(stream.index, countElements("betokened"))
            }
        }
        return result
    }

Most of the time it isn't necessary to write your own Recognizers. The problem with them is that they combine recognition with conversion of what is recognized into a token. It would be better to separate those, and so we can, using Parsers.

## Parsers

A Parser is a function that parses a portion of text and returns what it finds, including information about where in the underlying string the match was found. It has the signature `StringStream -> ParserResult?`. Parsers are more general than Recognizers and therefore more useful, though they must ultimately be combined with a Transformer using the `transform` function or operator `>>` to produce a Recognizer.

A good example can be found in the example above: `let betokened = string("betokened") >> { string, _ in Token.Literal(string) }`. Here, `string` is a Parser that attempts to match the string that's been given to it.

## Transformers

A Transformer is a function that takes a `String` and `Range<String.Index>` as arguments and returns a user-defined token. It has the signature `(String, Range<String.Index>) -> T`. These are always used with the `transform` function or `>>` operator to produce Recognizers from Parsers, e.g. `string("betokened") >> { string, _ in Token.Literal(string) }`.

## Partial Application

Many built-in Parsers and Recognizers uses Swift's awesome partial application capabilities as follows:

    func string(match: String)(stream: StringStream) -> ParserResult?

This is because most Parsers and Recognizers must take arguments, but they also need to conform to the type signature of their respective type. Partial application makes this possible.

## Dependencies

This library depends on my [Prosumma](https://github.com/Prosumma/Prosumma) framework, which is a grab bag of stuff I use in various projects. (Well, that's the intent. As of this writing it's rather empty.)
