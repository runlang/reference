#lang brag

program: addressable-expression

comment: COMMENT

block: /"{" addressable-expression /"}"

label: IDENT /":" expression* addressable-expression

@addressable-expression: expression* label?

concurrent : /"concurrent" expression (/"," expression)+

@expression: concurrent | comment | block | if | literal | "(" expression ")" | call | to-undo | undo-to | cancel-expression
             |  identifier | to

identifier: IDENT

to-undo: /"to" /"undo" expression

undo-to: /"undo" /"to" IDENT

cancel-expression: /"cancel" IDENT

literal: boolean | number | string

boolean: "true" | "false"

number: INTEGER

string: STRING

if: /"if" expression block (/"else" (block | if))?

call: IDENT /"(" (arg)? (/"," arg)* /")"

@ident-or-keyword: IDENT | keyword

arg: ident-or-keyword /":" expression

keyword: "and" | "or" | "if" | "else" | "true" | "false" | "to" | "undo" | "cancel" |"is"

arg-def: ident-or-keyword /":" IDENT

to: /"to" IDENT /"(" (arg-def)? /(/"," arg-def)* /")" expression