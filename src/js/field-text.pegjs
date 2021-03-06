start
    = _ expr:ORExpression _ { return expr }

operator
    = chars:[A-Z]+ { return chars.join('') }

ORExpression
    = first:ANDExpression rest:( __ ORBoolean __ ANDExpression)+    {
         return rest.reduce(function(memo, curr) {
            return {boolean: curr[1], left: memo, right: curr[3]};
         }, first);
     }
    / ANDExpression

ANDExpression
    = first:NOTExpression rest:( __ ANDBoolean __ NOTExpression)+    {
         return rest.reduce(function(memo, curr) {
            return {boolean: curr[1], left: memo, right: curr[3]};
         }, first);
     }
    / NOTExpression

NOTExpression
    = 'NOT' __ expr:fieldExpression { expr.negative = !expr.negative; return expr; }
    / fieldExpression

fieldExpression
    = operator:operator '{' csv:csv '}' colonsv:colonsv { return { operator: operator, values: csv , fields: colonsv}; }
    / '(' _ expr:ORExpression _ ')' { return { fieldtext: expr }; }

ORBoolean
    = 'OR'
    / 'XOR'
    / 'EOR' { return 'XOR' }

ANDBoolean
    = 'AND'
    / 'WHEN'
    / 'BEFORE'

colonsv
    = ':' head:field tail:colonsv { return [head].concat(tail); }
    / ':' field:field { return [field]; }

csv
    = csvPrime
    / '' { return []; }

csvPrime
    = head:value ',' tail:csvPrime { return [head].concat(tail); }
    / val:value { return [val]; }

field
    = chars:[A-Za-z0-9_/]+ { return chars.join(''); }

value
    = chars:[^,{}]+ { return chars.join(''); }

_
    = ' '*

__
    = _'+'_
    / ' '+
