/*
 * This is the grammar for the zen template engine
 */

{
  data = { foo:['C','D','E'], a:'hi', b:'there' };
  templates = { test:function (i_, d_) { return 'test('+i_(null,d_)+d_+')'; } };
  function L(a) {console && console.log(a)}
}

start 
  = fn:template
    { return fn(null, data); }

template
  = element_desc

/*
 * element_desc is where we combine nodes and things together. 
 */
element_desc
  /*
   * Add a child node.  A text interpolation is a kind of child node.
   */
  = elem:element_def ( '>' / & '{' ) child:element_desc
    { 
      return function (i_, d_) { 
        return elem(function (i__, d__) {
          return (i_ ? i_(null, d__) : '') + child(i__, d__);
        }, d_); 
      }; 
    }
  /*
   * Insert a template expansion as a child.  Call the template,
   * sending it either the same data as current, or expand it for a
   * slot in the current object.  If the slot contains an array, then
   * expand it for each element in the array.
   */
  / elem:element_def '>' ? '&' template:js_ref ( '(' field:js_ref ')' )?
    { 
      return function (i_, d_) {
        return elem(function (i__, d__) {
          field = field ? d__[field] : d__;
          return (i_ ? i_(null, d__) : '') + child(i__, d__);
        }, d_); 
      }; 
    }
  /*
   * Insert a sibling.  Puts the right hand element immediately after
   * the left hand one.
   */
  / elem:element_def '+' sibling:element_desc
    { return function (i_, d_) { 
        return elem(null, d_) + sibling(null, d_); }; }
  /*
   * Expand a template as a sibling.
   */
  /*
   * This is the rightmost element in the tree.  Nothing magical here.
  / elem:element_def
    { return function (i_, d_) { 
        return elem(i_, d_); }; }

/*
 * element_def is where we apply all the element modifiers to the
 * element.  It is a lot of the smarts, since it converts lower level
 * stuff into a function that takes child elements to put after
 * whatever text is in this element and the data structure that this
 * template is expanding over.
 */
element_def  
  = '{' interp:interpolation '}'
    { return interp; }
  / '(' elem:element_desc ')'
    { return elem; }
  / name:element_name mods:element_modifier *
    { 
      var id = '',
          cls = '',
          attr = '',
          repeat = 1,
          loop = null,
          i, mod, val;
      for (i = 0; i < mods.length; ++i) {
        mod = mods[i][0];
        val = mods[i][1];
        if (mod === 'id') {
          id = val;
        } else if (mod === 'class') {
          cls += (cls ? ' ' : '') + val;
        } else if (mod === 'attr') {
          attr += ' ' + val + '=' + mods[i][2];
        } else if (mod === 'repeat') {
        } else if (mod === 'repeat_ref') {
        }
      }
      attr += id ? ' id="'+id+'"' : '';
      attr += cls ? ' class="'+cls+'"' : '';
      return function (i_, d_) { 
        return '<' + name + attr + '>' + (i_ ? i_(null, d_) : '') + '</' + name + '>'; 
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
  / '*' ref:js_ref
    { return ['repeat_ref', ref]; }
///  / '&' ref:js_ref ( '(' field:js_ref ')' )?
///    { return ['template_ref', ref, field]; }

element_name
  = name:xml_elem 
    { return name; }
  / "" 
    { return 'div'; }

interpolation
  = pre:interpolation_no_match matches:(interpolation_value interpolation_no_match)*
    { 
      return function (i_, d_) {
        var result = pre, i;
        for (i = 0; i < matches.length; ++i) {
          result += d_[matches[i][0]] + matches[i][1];
        }
        return result + (i_ ? i_(null, d_) : '');
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
