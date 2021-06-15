#lang scribble/manual

@(require racket/system racket/port racket/syntax)

@(define (tbc)
   @italic{TO BE CONTINUED})

@(define-syntax run-codeblock
   (syntax-rules ()
     [(_ expr ...)
      (codeblock #:keep-lang-line? #f "#lang runlang/reference\n" expr ...)
     ]))

@title[#:version (with-output-to-string (lambda () (system "git describe --always --tags")))
       "Run Language"]
@author[(author+email "Yurii Rashkovskii" "yrashk@gmail.com")]

This is a working draft of the Run Language motivation, specification
and reasoning.

@table-of-contents{}

@section{Introduction}

Clarity in business processes spanning organizational structures,
software systems and domains is an ongoing concern. Runaway complexity,
underspecified procedures lead to erroneous actions or lack of appropriate
actions, increase management overhead and inflate costs of automation and its maintenance. 

Run is a modern, high-level language for defining, deploying and
maintaining the lifecycle of executable business processes that is designed
to address such concerns.

@section{Background}

@margin-note*{There are a lot of existing business process languages, including but not
limited to BPDM, BPEL4WS, BPML, BPMN, BPSS, EPML, OWL-S, PNML, UML Activity Diagram, WS-CDL,
WSCI, WSCL, WSFL, XLANG, XPD, XPDL, YAWL}
In the past few decades, a lot of efforts have been made to formalize workflow
patterns into a language that can be used by non-technical and technical stakeholders
alike in order to maintain a shared understanding of processes, reasoning and decision
making. This has resulted in development and adoption of such languages as BPEL, BPMN, YAWL
and alike.

In this section, for the purpose of clarity, we'll focus on BPMN as a baseline.
It's a well-established and documented language supported by multiple software vendors.

There are a few important properties that BPMN has:

@itemlist[
 @item{Visual language (flow diagrams) that provides a comprehensive, bird's-eye view}
 @item{Execution semantics that allow for a mechanical interpretation (@italic{execution}) of documents}
 @item{Introduction of useful standard workflow primitives such as events, boundary events,
      timers, compensations and so on to enable standardized handling of complex cases}
]

BPMN does come with some trade offs:

@itemlist[
 @item{
       @margin-note*{Examples:
                    
       @italic{Complex Gateway}, what does it do?

       What's the difference between a @italic{signal} and a @italic{message}?
       How does message delivery differ based on the kind of @italic{correlation} used?}
       The flow elements have their execution semantics defined and one needs to know
       to construct the flow in a correct manner. Therefore, it implies the need for
       a translation between processes laid out in a natural language to the language
       of activation of flow elements according to their execution semantics. So, instead of describing
       what @italic{needs to occur}, one needs to model according to what the flow element or their composition
       will do. It gets especially challenging when flow element's own naming does not reveal its function.
 }
  
 @item{Authoring diagrams is not the most natural user experience. A significant amount
       of research needs to be done in order to figure out a truly effective way to author diagrams,
       considering the amount of possibilities afforded by the standard. It becomes even more difficult
       if the document needs to be executable, as it'll start requiring changes of authoring mode between the diagram,
       flow element properties and text-based expressions.}
 
 @item{Authoring programs (because executable documents are effectively programs) as diagrams is not the most
       anticipated approach for most of software engineers and it is not the best fit for their tooling and practices.
       While BPMN documents are XML documents and can be edited as text, at that point they become counter-productive
       as authoring through long-winded XML formalisms makes it difficult to both write and read them, therefore defying
       the core promise of providing understanding and a high-level view.}
 
 @item{Lack of composition. While almost any workflow can be expressed in BPMN, it can become repetitive if certain
       patterns are to occur repeatedly. As an example, we can imagine a case for re-trying an activity with an exponential
       backoff, with a maximum number of retries. It's implementable, but copying it around can quickly become a chore and be error-prone.
       }

 @item{Lack of first-class execution tracing. @tbc{}}       
]


@bold{We propose} that one can derive benefits from patterns identified in by BPMN
and similar approaches while mitigating the aforementioned trade-offs by introducing a
high level text-based language that focuses on @italic{what needs to occur} as opposed to
connecting flow elements that have their own behavior. It will allow to express complex
behaviours that don't need to be deconstructed through the prism of flow elements'
execution semantics.

The language should be at least somewhat familiar to software engineers to be
accepted as a reasonable tool in their toolbox and play well with established
practices.

At the same time, the language should bear at least some level of general
readability to avoid it being a complete gibberish for those who aren't software
engineers.

The language should also retain the high level intent of the authors in order to
be transformable to and from different representations, such as visual diagrams
(as these are indeed very useful for process comprehension).

This document introduces the @bold{Run Language} to address this proposition.

@section{Goals}

@subsection{Platform Pervasiveness}

It is important that Run programs can operate in different environments and platforms, such as
servers and workstations, mobile devices, browsers, microcontrollers, etc. Being able to describe
processes that span operational backends, consumer and IoT devices allows for most comprehensive
capture of the domain.

@subsection{Compilation}

Run is intended to be run using a small specialized VM (@italic{Virtual Machine}) in order to spare
each platforms from implementing a parser and a high-level interpreter. This ensures it is easier
to implement Run environments on any platform.

Going further, it is highly desirable to make language compilable to other targets, such as @italic{native code}
(for @bold{performance}), other languages (for @bold{cohesive integration}) and special environment languages,
such as @italic{smart contract languages} in @bold{blockchains} or @italic{verification} languages such as
@(link "http://why3.lri.fr/doc/syntaxref.html" "WhyML") for @bold{critical processes}.

@subsection{Ease of Comprehension}

Run programs should be easily comprehensible in their textual and other representations with little familiarity
of its specifics. In other words, programs should be self-explanatory at least at a high-level.

Ease of comprehension affects many areas of language's design: from syntax, semantics to naming and other conventions.

@subsection{Intent Retention}

To the extent possible, Run programs should be able to retain the original intent of the author
without having it conceptualized using a different domain language.

This specification expends an effort to avoid @italic{naming things} where possible in order to avoid
such conceptualization.

@subsection{Observability}

@tbc{}

@subsection{Continuous Capture}

Run acknowledges that the world never stops and changes continue to occur. To that end, it is designed
to support continuous information passage. This is also known as @italic{streaming}.

@section{Non-Goals}

@subsection{Self-hosting}

Run is intended to be a high-level language, gluing other systems and orchestrating the workflows. It is
not intended to be a general purpose language and there's little to no benefit in making it possible to
implement Run in Run.

@section{Typing}

Run employs a lightweight static typing system to ensure that the values used throughout
its programs can be validated ahead of execution.

@tbc{}

@section{Expressions}

This section presents basic expressions (building blocks) of the core language. More forms are introduced in other
sections.

@subsection{Comments}

Comments are considered expressions because they can be used to annotate the program and these annotations
can be used when transforming programs to other representations, such as diagrams. Even more importantly,
since they are considered first-class expressions, they can be used in place of other @italic{executable}
expressions in under-specified programs that can only be executed in simulation that assigns typed values
to these expressions.

Line comments start with a double-slash (@litchar{//}) or a pound (hash) sign (@litchar{#}) and run until the end of the line
or the end of the file (whichever occurs first)

Block comments start with a slash followed by an asterisk (@litchar{/*}) and run until a closing asterisk followed
by a slash (@litchar{*/}). Nested block comments are supported.

@run-codeblock[]|{
# This is a line comment
// This is a line comment
/* This is a block comment
   that spans multiple lines
*/
}|

@subsection{Literals}

Literals are expressions that evaluate to themselves.

@subsubsection{Booleans}

Boolean can be either @code{true} or @code{false}.

@subsubsection{Strings}

Strings are UTF-8 encoded Unicode strings and are enclosed between matching double (@litchar{"}) quotes. The double quote character can be
escaped with a blackslash (@litchar{\}). Backslash can be escaped with an extra backslash.

Strings can span multiple lines. If follow-up lines are indented to start at a column following the column of the opening quote,
the leading whitespace will be removed.

@codeblock[]|{
"This is a string"
"This is what we call a \"string\""
"This is a blackslash: \\"
"This is a
 multi-line string"
}|

@subsubsection{Numbers}

Numbers can be either integers or floating-point numbers.

@subsubsection{Integers}

Decimal integers are of the following format: `[-](0-9)+` and can be interspersed with underscore (`_`) to ease comprehension (`100_000_000` being
equivalent to `100000000`). The underscore can not be adjacent to period (`.`) or the optional sign.

Binary integers can be encoded using the notation of leading zero and a lowercase letter 'b' (`0b`) followed by a sequences of zeroes and ones.

Octal integers can be encoded using the notation of leading zero and a lowercase leter 'o' (`0o`) followed by a sequence of `0-7`.

Hexadecimal integers can be encoded using the notation of leading zero and a lowercase letter 'x' (`0x`) followed by a sequence of `0-F`.

All binary, octal and hexadecimal integers can be interspersed with underscore (`_`) to ease comprehension as well. They can not, however, start with the
underscore.

@subsubsection{Floating-point}

Decimal floating-point numbers are of the following format: `[-](0-9)+\.(0-9)+` and can be interspersed with underscore (`_`) to ease comprehension (`100_000_000.00` being
equivalent to `100000000.00`). The underscore can not be adjacent to period (`.`) or the optional sign.

@subsubsection{Scientific Notation}

Scientific notation can also be used. It follows the format of `[-](0-9)+(\.(0-9)+)?[E|e]-?(0-9)+`. It can also be interspersed with underscore (`_`) to ease comprehension except
adjacent to `E` or `e` and the (optional) sign.

@subsection{Call}

This is one of the most useful building blocks. Since Run Language is mostly seen as a glue to connect various pieces, it needs to call into other systems, as well as being
able to re-use building blocks defined in it.

@tbc{}

@subsection{Logical Expressions}

@itemlist[
  @item{@bold{Logical AND}: @code{expr1 and expr2} is a boolean expression stating that both @code{expr1} and @code{expr2} have to be @code{true} in order for this expression to be @code{true}}
  @item{@bold{Logical OR}: @code{expr1 or expr2} is a boolean expression stating that either @code{expr1} or @code{expr2} have to be @code{true} in order for this expression to be @code{true}}
  @item{@bold{Logical NOT}: @code{not expr} is a boolean expression stating that @code{expr} should be @code{false} in order for this expression to be @code{true}}
]

@subsection{Comparison Expressions}

@itemlist[
 @item{@bold{Equal}: @code{expr == expr2} is a boolean expression stating that @code{expr1} must be equal to @code{expr2} in order for this expression to be @code{true}}
 @item{@bold{Unequal}: @code{expr != expr2} is a boolean expression stating that @code{expr1} must not be equal to @code{expr2} in order for this expression to be @code{true}}
 @item{@bold{Less}: @code{expr < expr2} is a boolean expression stating that @code{expr1} must be strictly less than @code{expr2} in order for this expression to be @code{true}}
 @item{@bold{Less or equal}: @code{expr <= expr2} is a boolean expression stating that @code{expr1} must less than or equal to @code{expr2} in order for this expression to be @code{true}}
 @item{@bold{Greater}: @code{expr > expr2} is a boolean expression stating that @code{expr1} must be strictly greater than @code{expr2} in order for this expression to be @code{true}}
 @item{@bold{Greater or equal}: @code{expr >= expr2} is a boolean expression stating that @code{expr1} must greater than or equal to @code{expr2} in order for this expression to be @code{true}}
]

@subsection{Arithmetic Expressions}

@tbc{}

@subsection{Grouping Expresssion}

Expressions can be groupped using parentheses: ( and ). For example, @code{1 + 2 * 2} evaluates to @code{5}, but @code{(1 + 2) * 2} evaluates to @code{6}.

@subsubsection{Precedence}
@tbc{}

@subsection{Block}

A block expression is simply a grouped sequence of expressions enclosed within curly brackets. It implies sequential interpretation of these contained expressions.

@run-codeblock|{
{
   // expression E_0
   // ...
   // expression E_n
}
}|

@subsection{Pure Expressions}

All expressions that are idempotent and have no side effects are considered pure. The best way to think of this is to consider a class of expressions
that do not alter the state of the execution in any way (even such as making any calls, even if they are idempotent). 

@subsection{Conditional Expressions}

A conditional @code{if} expression is used to make a choice based on a boolean-typed @italic{pure expression}
@margin-note*{Purety of the condition expression is important to ensure that it can be executed any number of times without any effect to the execution}
(@italic{condition}), followed by a block expression to execute in case if the boolean expression evaluated to @code{true} and optional @code{else}
conditional or block expression in case if it evaluated to @code{false}.

@run-codeblock|{
if /* bool expression */ { /* expression Esuccess> ... */ }
}|

@run-codeblock|{
if /* bool expression */ {
  /* expression Esuccess ...*/
} else {
  /* expression Efail ... */
}
}|

@run-codeblock|{
if /* bool expression */ {
  /* expression Esuccess ... */
} else if /* bool expression */ {
  /* ...  */
} 
}|

There are a few reasons why success and failure expressions can only be block expressions:

Firstly, it resolves the ambiguity of @code{else} branches in the following case (should non-block expressions have been allowed):

@codeblock|{
if condition doSomething()
if anotherCondition doSomethingElse()
else doTheOpposite()
}|

To which @code{if} condition does the @code{else} branch belong?

Secondly, it has been @(link "https://www.imperialviolet.org/2014/02/22/applebug.html" "known") that @code{if} branches without curly brackets can lead
to mispercepted boundaries, so it's best to avoid them.

@subsection{Concurrent Expressions}

A concurrent expression is formed by using @code{concurrent} expression and a comma-separated list of expressions that are concurrent to
each other.

@run-codeblock|{
concurrent a(), b(), c()
}|

These expressions are one of the most important building blocks of Run programs as they allow to describe logic that
should happen concurrently, and is a basis for a lot of common workflow patterns.


@subsection{Undo Expressions}

At any time in the code, a @code{to undo} expression can be specified
to add a code path that is invoked when the @code{undo to} expression is used. Undo expressions are executed concurrently. 

Example:

@run-codeblock|{
  book_flight()
  to undo cancel_flight()
  
  book_hotel()
  to undo cancel_hotel()
}|


@subsection{Definition Expressions}

@subsection{Iteration}

