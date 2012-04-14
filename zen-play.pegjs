
/* grammar for zen template engine */

{
    function fns(str) {
        return function () { return res; };
    }
    function fne(str) {
        return function (c) { 
            return "<"+str+">" + c() + "</"+str+">"; 
        };
        
    }
}

start = template

template 
    = element_desc
//     = element ( '>' element / '+' element ) 
//         { }
//     / literal_text
//     / js_ref
//     / template_ref

// element 
//     = xml_symbol ( modifier ) *
//     / '(' template ')'

element_desc 
    = element_desc element_modifier
    / element_name

element_modifier 
    = '+' element_desc
    / '>' element_desc
    / filtered_literal_text
    / filtered_js_ref
    / filtered_template_ref

element_name
    = xml_elem_symbol

opt_filter 
    = '|' filter:[huj]

literal_text 
    = '{' text:[^}]+ '}'
        { return fns(text.join('')); }

js_ref 
    = '$' js_symbol

template_ref 
    = '&' js_symbol

quoted_literal 
    = '"' letters:[^"]* '"'
        { return fns(letters.join('')); }

simple_literal 
    = letters:[^ \]]+
        { return fns(letters.join('')); }

js_symbol 
    = letters:([a-zA-Z] [a-zA-Z0-9_]+)
        { return fns(letters.join('')); }

xml_elem_symbol 
    = letters:[a-zA-Z]+ 
        { return fns(letters.join('')); }

xml_attr_symbol 
    = letters:[-_a-zA-Z0-9]+
        { return fns(letters.join('')); }






/////////////////////////////////////////////


/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */

start
  = template

//additive
//  = left:multiplicative "+" right:additive { return left + right; }
//  / multiplicative
//
//multiplicative
//  = left:primary "*" right:multiplicative { return left * right; }
//  / primary
//
//primary
//  = integer
//  / "(" additive:additive ")" { return additive; }
//
//integer "integer"
//  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }

template
  = element_desc

element_desc
  = elem:element_def '>' child:element_desc
  / elem:element_def '+' child:element_desc
  / elem:element_def

element_def
  = name:element_name mods:element_modifier *
    { return { 'name':name, 'mods':mods }; }

element_modifier
  = '.' xml_attr_val
  / '#' xml_attr_val
  / '*' count:int 
    { return {'repeat' : count }; }
  / '{' text:literal_text '}'
    { return {'literal' : text }; }
  / '*' js_ref
  / '=' js_ref
  / '&' js_ref

element_name
  = name:xml_elem 
    { return {'name':name}; }
  / "" 
    { return {'name':'div'}; }

int
  = digits:[0-9]+ 
    { return parseInt(digits.join(""), 10); }

js_ref
  = chars:[a-zA-Z$_]+ 
    { return chars.join(''); }

literal_text
  = chars:[^}]* 
    { return chars.join(''); }

xml_elem 
  = chars:[a-zA-Z]+ 
    { return chars.join(''); }

xml_attr_val
  = chars:[-0-9a-zA-Z]+ 
    { return chars.join(''); }


//----------------------------------------------------------------------------

/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */

start
  = template

template
  = element_desc

element_desc
  = elem:element_def '>' child:element_desc
  / elem:element_def '+' child:element_desc
  / elem:element_def

element_def
  = name:element_name mods:element_modifier *
    { return { 'name':name, 'mods_to_apply':mods }; }

element_modifier
  = '.' text:xml_attr_val
    { return ['class', text]; }
  / '#' text:xml_attr_val
    { return ['id', text]; }
  / '*' count:int 
    { return ['repeat', count]; }
  / '{' text:literal_text '}'
    { return ['literal', text]; }
  / '*' ref:js_ref
    { return ['repeat_ref', ref]; }
  / '=' ref:js_ref
    { return ['include_ref', ref]; }
  / '&' ref:js_ref
    { return ['template_ref', ref]; }

element_name
  = name:xml_elem 
    { return {'name':name}; }
  / "" 
    { return {'name':'div'}; }

int
  = digits:[0-9]+ 
    { return parseInt(digits.join(""), 10); }

js_ref
  = chars:[a-zA-Z$_]+ 
    { return chars.join(''); }

literal_text
  = chars:[^}]* 
    { return chars.join(''); }

xml_elem 
  = chars:[a-zA-Z]+ 
    { return chars.join(''); }

xml_attr_val
  = chars:[-0-9a-zA-Z]+ 
    { return chars.join(''); }


