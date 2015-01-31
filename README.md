# Betokened

**Betokened** is a simple little Swift library that turns a string into an array of tokens. It has the following goals:

- It always tokenizes an underlying string.
- It is designed to be as simple and straightforward as possible.
- Custom operators are available to simplify syntax.

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

    // Perform the tokenization and prin the result
    switch tokenizer.tokenize("   betokened   ") {
        case .Ok(let tokens): println(tokens)
        case .Err(let error): println(error)
    }


