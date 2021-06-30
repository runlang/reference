#lang racket/base

(require "lexer.rkt" brag/support racket/match)

(define (run-colorer port)
  (define (handle-lexer-error excn)
    (define excn-srclocs (exn:fail:read-srclocs excn))
    (srcloc-token (token 'ERROR) (car excn-srclocs)))
  (define srcloc-tok
    (with-handlers ([exn:fail:read? handle-lexer-error])
      (run-lexer port)))
   (match srcloc-tok
    [(? eof-object?) (values srcloc-tok 'eof #f #f #f)]
    [else
     (match-define
       (srcloc-token
        (token-struct type val _ _ _ _ _)
        (srcloc _ _ _ posn span)) srcloc-tok)
     (define start posn)
     (define end (+ start span))
     (match-define (list cat paren)
       (match type
         ['STRING '(string #f)]
         ['INTEGER '(constant #f)]
         ['COMMENT '(comment #f)]
         ['IDENT '(symbol #f)]
         [else (match val
                 [(? number?) '(constant #f)]
                 [(? symbol?) '(symbol #f)]
                 ["(" '(parenthesis |(|)]
                 [")" '(parenthesis |)|)]
                 ["{" '(parenthesis |{|)]
                 ["}" '(parenthesis |}|)]
                 [else
                  (if (member val keywords)
                      ;; It's not a #:keyword, but at least
                      ;; it gets a different color for a keyword
                      '(hash-colon-keyword #f)
                  '(no-color #f))])]))
     (values val cat paren start end)]))

(provide run-colorer)