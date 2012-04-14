/*
 * This is the grammar for the zen template engine
 */

{
  data = { foo: 1 };
}

start
  = fn:template
    { return fn('', data); }

template
  = element_desc

/*
 * element_desc is where we combine nodes (including occasionally text
 * interpolations) together. 
 */
element_desc
  = elem:element_def '>{' interp:interpolation '}'
    { return function () { 
        return elem(interp, data); }; }
  / elem:element_def '>' child:element_desc
    { return function () { 
        return elem(child, data); }; }
  / elem:element_def '+{' interp:interpolation '}'
    { return function () { 
        return elem(null, data) + interp(null, data); }; }
  / elem:element_def '+' sibling:element_desc
    { return function () { 
        return elem(null, data) + sibling(null, data); }; }
  / elem:element_def
    { return function () { 
        return elem(); }; }

/*
 * element_def is where we apply all the element modifiers to the
 * element.  It is a lot of the smarts, since it converts lower level
 * stuff into a function that takes child elements to put after
 * whatever text is in this element and the data structure that this
 * template is expanding over.
 */
element_def  
  = name:element_name mods:element_modifier *
    { 
      var id = '',
          cls = '',
          attr = '',
          txt = function () { return ''; },
          i, mod, val;
      for (i = 0; i < mods.length; ++i) {
        mod = mods[i][0];
        val = mods[i][1];
        if (mod === 'id') {
          id = val;
        } else if (mod === 'class') {
          cls += (cls ? ' ' : '') + val;
        } else if (mod === 'literal') {
          txt = (function (told) { return function () { return told() + val; } })(txt);
        } else if (mod === 'attr') {
          attr += ' ' + val + '=' + mods[i][2];
        }
      }
      attr += id ? ' id="'+id+'"' : '';
      attr += cls ? ' class="'+cls+'"' : '';
      return function (insert, data) { 
        return '<'+name+attr+'>'+(insert?insert():'')+txt()+'</'+name+'>'; 
      }; 
    }

element_modifier
  = '.' text:xml_attr_val
    { return ['class', text]; }
  / '#' text:xml_attr_val
    { return ['id', text]; }
  / '[' name:xml_attr_val '=' text:( simple_literal / quoted_text ) ']'
    { return ['attr', name, text]; }
  / '*' count:int 
    { return ['repeat', count]; }
  / '{' interp:interpolation '}'
    { return ['interp', interp]; }
  / '*' ref:js_ref
    { return ['repeat_ref', ref]; }
  / '=' ref:js_ref
    { return ['include_ref', ref]; }
  / '&' ref:js_ref
    { return ['template_ref', ref]; }

element_name
  = name:xml_elem 
    { return name; }
  / "" 
    { return 'div'; }

interpolation
  = pre:interpolation_no_match matches:(interpolation_value interpolation_no_match)*
    { 
      return function (child, data) {
        var result = pre, i;
        for (i = 0; i < matches.length; ++i) {
          result += data[matches[i][0]] + matches[i][1];
        }
        return child?child(null, data):'' + result;
      }
    }

interpolation_no_match 
  = ch:( '\\$' / '\\}' / [^}$] )* 
    { 
      var i; 
      for (i = 0; i < ch.length; ++i) { 
        if (ch[i].length === 2) {
          ch[i] = ch[i].substr(1,1); 
        } 
      }
      return ch.join(''); 
    }

interpolation_value
  = '$' ch:( [$_a-zA-Z] [$_a-zA-Z0-9]* )
    { return ch[0] + ch[1].join(''); }
  / '${' ch:( [^}]* ) '}' 
    { return ch.join(''); }

quoted_text
  = '"' chars:[^"] * '"'
    { return '"'+chars.join('')+'"'; }

int
  = digits:[0-9]+ 
    { return parseInt(digits.join(""), 10); }

js_ref
  = chars:[a-zA-Z$_]+ 
    { return chars.join(''); }

simple_literal
  = chars:[a-zA-Z0-9]+
    { return chars.join(''); }

literal_text
  = chars:[^}]* 
    { return chars.join(''); }

xml_elem 
  = chars:[a-zA-Z]+ 
    { return chars.join(''); }

xml_attr_val
  = chars:[-_0-9a-zA-Z]+ 
    { return chars.join(''); }

