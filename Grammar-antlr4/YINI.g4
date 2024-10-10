/*
 YINI grammar in ANTLR 4.
 Apache License, Version 2.0, January 2004,
 http://www.apache.org/licenses/
 Copyright 2024 Gothenburg, Marko K. Seppänen (Sweden via
 Finland).
 */

// This grammar should follow YINI specification version 1.0 Alpha 2. Please note, they might be
// smaller or bigger unknown bugs or issues.

grammar yini;
options {
	caseInsensitive = false;
}

yini: SHEBANG? NL* section+ NL*;

//main_section
// : section_head (section_members | section)+ NL*;

fragment EBD: ('0' | '1') ('0' | '1') ('0' | '1');

section:
	section_head section_members
	| section_head section NL+;

section_head: '#'+ IDENT NL+; //	| TERMINAL_TOKEN

TERMINAL_TOKEN options {
	caseInsensitive = true;
}: '###' WS* POSSIBLE_END_COMMENT? NL* EOF; //    : '***'

POSSIBLE_END_COMMENT: '//' () .*?;

section_members: member+;

member:
	IDENT '=' value NL+
	| IDENT ':' NL* list NL+
	| TERMINAL_TOKEN
	| IDENT '=' NL+;

value: string_ | NUMBER | BOOLEAN;

NUMBER:
	INTEGER ('.' INTEGER?)? EXPONENT?
	| SIGN? '.' DIGIT+ EXPONENT?
	| SIGN? '0' (
		BIN_INTEGER
		| OCT_INTEGER
		| DUO_INTEGER
		| HEX_INTEGER
	);

// Note: 0 or higher than 1, no leading 0s allowed (for ex: `01`)
fragment DECIMAL_INTEGER: '0' | SIGN? [1-9] DIGIT*;

fragment INTEGER: DECIMAL_INTEGER;
fragment BIN_INTEGER: ('b' | 'B') BIN_DIGIT+;
fragment OCT_INTEGER: ('o' | 'O') OCT_DIGIT+;
fragment DUO_INTEGER: ('z' | 'Z') DUO_DIGIT+;
fragment HEX_INTEGER: ('x' | 'X') HEX_DIGIT+;

//fragment FLOAT : DECIMAL_INTEGER '.' DECIMAL_INTEGER;

fragment DIGIT: [0-9];

fragment BIN_DIGIT: '0' | '1';
fragment OCT_DIGIT: [0-7];
fragment DUO_DIGIT: DIGIT | [xe] | [XE]; // x = 10, e = 11.
fragment HEX_DIGIT: DIGIT | [a-f] | [A-F];

fragment FRACTION: '.' DIGIT+;

fragment EXPONENT: ('e' | 'E') SIGN? DIGIT+;

fragment SIGN: ('+' | '-');

BOOLEAN options {
	caseInsensitive = true;
}: ('true' | 'yes' | 'on') | ('false' | 'no' | 'off');

list: elements | list_in_brackets;

list_in_brackets: '[' NL* elements NL* ']';

elements: element ','? | element ',' elements;

element: NL* value NL* | NL* list_in_brackets NL*;

SHEBANG: '#!' ~[\n\r\b\f\t]* NL;

IDENT: ('a' ..'z' | 'A' ..'Z' | '_') (
		'a' ..'z'
		| 'A' ..'Z'
		| '0' ..'9'
		| '_'
		| '-'
	)*;

//STRING: P_STRING | C_STRING;

string_:
	SINGLE_STRING NL* '+' NL* SINGLE_STRING
	| SINGLE_STRING;

SINGLE_STRING: P_STRING | C_STRING;

// Pure string literal.
P_STRING:
	'\'' (~['\n\r\b\f\t])* '\''
	| '"' ( ~["\n\r\b\f\t])* '"';

// Classic string literal.
C_STRING: ('c' | 'C') '\'' (ESC_SEQ | ~('\''))* '\''
	| ('c' | 'C') '"' ( ESC_SEQ | ~('"'))* '"';

// Note: Like 8.2 in specification.
ESC_SEQ: '\\' (["']) | ESC_SEQ_BASE;

// Note: Except does'n not include quotes `"`, `'`.
ESC_SEQ_BASE: '\\' ([nrbft\\/] | UNICODE);

fragment UNICODE: 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT;

NL: ('\r' '\n'? | '\n');

WS: [ \t]+ -> skip;

BLOCK_COMMENT:
	'/*' .*? '*/' -> skip; // Block AKA Multi-line comment.

LINE_COMMENT: '//' ~[\r\n]* -> skip;