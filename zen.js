var zenTemplate;

(function () {
    var this,
        tokens,
        tokenize = function (str) {
            var ops = {
                    ' ' : 'SPACE',
                    '>' : 'GREATER_THAN',
                    '+' : 'PLUS',
                    '(' : 'OPEN_PAREN',
                    ')' : 'CLOSE_PAREN',
                    '.' : 'PERIOD',
                    '#' : 'OCTOTHORPE',
                    '&' : 'AMPERSAND',
                    '*' : 'SPLAT',
                    '$' : 'DOLLAR',
                    '[' : 'OPEN_BRACE',  // TODO: verify brace vs.  bracket
                    ']' : 'CLOSE_BRACE',
                    '{' : 'OPEN_BRACKET',
                    '}' : 'CLOSE_BRACKET',
                    '=' : 'EQUALS',
                    'h' : 'LETTER_H',
                    'u' : 'LETTER_U',
                    'j' : 'LETTER_J' },
                op = function (ch) {
                    tokens.push([ops[ch]]);
                },
                lit = function (text) {
                    tokens.push(['LIT', text]);
                },
                first, rest, word;

            while (str.length > 0) {
                first = str.substr(0, 1);
                rest = str.substr(1);
                if (first.match(/^[ >+().#&*$[\]}]/)) {
                    op(first);
                    str = rest;
                } else if (first === '{') {
                    op(first);
                    word = rest.match(/^[^}]*/);
                    literal(word[0]);
                    str = rest.substr(word[0].length);
                } else if (first === '=') {
                    op(first);
                    word = rest.match(/^[^\]]*/);
                    literal(word[0]);
                    str = rest.substr(word[0].length);
                } else if (word = str.match(/^[-_0-9a-zA-Z/+)) {
                    literal(word[0]);
                    str = rest.substr(word[0].length);
                } else { 
                    // TODO: throw the right kind of thing here.
                    throw 'SYNTAX ERROR';
                }
        },
        matchTokens = function () {
        },
        consume = function (count) {
            var i;
            for(i = 0; i < count; ++i) {
                tokens.unshift;
            }
        },
        parseTemplate = function (tokens) {
            var sub;
            if (matchTokens('OPEN_BRACKET', 'LIT', 'CLOSE_BRACKET')) {
            }
            var result = parseElement(tokens);
            while (tokens[0][0] === 'op' &&
                    tokens[1][1].match(/^[>+|]$/)) {
            }
        },
        parseTemplateRef = function (tokens) {
        },
        parseElement = function (tokens) {
        },
        parseFilter = function (tokens) {
        },
        parseModifier = function (tokens) {
        },
        parseAttrDefn = function (tokens) {
        },
        parseMultiplier = function (tokens) {
        },
        parseAttrOrRef = function (tokens) {
        },
        parseQuotedLiteral = function (tokens) {
        },
        parseSimpleLiteral = funciton (tokens) {
        },
        parseJsRef = function (tokens) {
        },
        parseJsSymbol = function (tokens) {
        },
        parseXmlElemSymbol = function (tokens) {
        },
        parseXmlAttrSymbol = function (tokens) {
        },

    zenTemplate = {
        rules: {},
        compiled: {},

        extendJQuery: function ($) {
            if (!$) { $ = jQuery; }
            $.fn.zen = function (data) {
            };
        },
    };
})();
   
/*************************************************************************
  * Language definition.
  *
  * (Using something EBNF-like since I don't recall exact EBNF.  {x}
  * means zero or more xs, [y] means zero or one y.  () means
  * grouping.  a|b|c means one of a, b or c.  'l' means a literal
  * "l".  /r/ means a literal that matches regex r.  ; starts a
  * comment.)
  * 
  * This is intended to be parsed with a hand-written LL(1) (recursive
  * descent with one token of lookahead) parser, and a simple
  * tokenizer built out of regular expressions.
  * 
  *
  * template := element { '>' element | '+' element | '|' filter }
  *     | '{' /^[^}]$/ '}'             ; literal text
  *     | js-ref                       ; a value from data
  *     | template-ref                 ; call a template
  *
  * template-ref := '&' js-symbol { modifier }
  *
  * element := xml-symbol { modifier }
  *     | '(' template ')'             ; grouping
  *
  * filter : 'h'                       ; HTML escape
  *     | 'u'                          ; URL escape
  *     | 'j'                          ; JSON escape
  *
  * modifier := '.' xml-attr-symbol    ; add a class name
  *     | '#' attr-or-ref              ; add an id
  *     | '[' attr-defn { ' ' attr-defn } ']'
  *     | '*' multiplier
  *
  * attr-defn := xml-attr-symbol [ '=' ( quoted-literal 
  *                                    | simple-literal
  *                                    | js-ref ) ]
  *
  * multiplier := /^[0-9]+$/           ; repeat N times
  *     | js-ref                       ; repeat over data
  *
  * attr-or-ref := xml-attr-symbol
  *     | js-ref
  *
  * quoted-literal := /^"[^"]*"/
  *
  * simple-literal := /^[^ \]]+/
  *
  * js-ref := '$' js-symbol
  *
  * js-symbol := /^[a-zA-Z][a-zA-Z0-9_]*$/ { // }
  *
  * xml-elem-symbol := /^[a-zA-Z]+$/
  *
  * xml-attr-symbol := /^[a-zA-Z][a-zA-Z0-9_-]*$/
  *
  * 
  * Tokens:
  *   '>' : Add a child element
  *   '+' : Add a sibling element
  *   '|' : Add an output filter
  *   '()' : Group elements
  *   '.' : Add class to element
  *   '#' : Add ID to element
  *   '{}' : Add literal text
  *   '&' : Reference another template
  *   '[]' : Add attributes to element
  *   '*' : Multiply previous element, or bind to data
  *   '$' : Data placeholder
   */
