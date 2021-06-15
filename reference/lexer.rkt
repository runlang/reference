#lang racket/base

(require brag/support)

(define keywords (list "and" "or" "if" "else" "true" "false" "to" "undo" "cancel" "is" "concurrent"))
(provide keywords)

(define-lex-abbrev ident (:seq (:or "_" alphabetic) (:* (:or alphabetic numeric "_"))))
(define-lex-abbrev integer (:seq (:? "-") (:+ numeric)))
(define-lex-abbrev string (:seq "\"" (:* any-char) "\""))

(define-lex-abbrev keyword (:or "and" "or" "if" "else" "true" "false" "to" "undo" "cancel" "is" "concurrent"))
  
(define run-lexer
  (lexer-srcloc
   [(from/to "/*" "*/") (token 'COMMENT lexeme)]
   [(from/stop-before "//" "\n") (token 'COMMENT lexeme)]
   [(from/stop-before "#" "\n") (token 'COMMENT lexeme)]
   ["\n" (token 'NEWLINE lexeme #:skip? #t)]
   [whitespace (token lexeme #:skip? #t)]
   [keyword (token lexeme lexeme)]
   ["..." (token 'IDENT lexeme)]
   [ident (token 'IDENT lexeme)]
   [integer (token 'INTEGER (string->number lexeme))]
   [string (token 'STRING (trim-ends "\"" lexeme "\""))]
   [(char-set "/#*/{}(),:|") (token lexeme lexeme)]))

(provide run-lexer)

(define (make-tokenizer port path)
  (define (next-token) (run-lexer port))
  next-token)

(provide make-tokenizer)

(module+ test
  (require rackunit racket/match)

  (define (tokenize string)
     (let ([tok (make-tokenizer (open-input-string string) #f)])
          (srcloc-token-token (tok))))
  )

(module+ test
  (test-case "Multi-line comment (in one line)"
      (let* ([comment  "/* test */"]
             [token (tokenize comment)])
         (check-equal? (token-struct-type token) 'COMMENT)
         (check-equal? (token-struct-val token) comment)
        ))
  (test-case "Multi-line comment"
      (let* ([comment "/* test
                              */"]
             [token (tokenize comment)])
         (check-equal? (token-struct-type token) 'COMMENT)
         (check-equal? (token-struct-val token) comment)
        ))
  (test-case "Multi-line comment with a nested multi-line comment"
      (let* ([comment "/* test /* test */ */"]
             [token (tokenize comment)])
         (check-equal? (token-struct-type token) 'COMMENT)
         ; FIXME: this doesn't work yet
         ;(check-equal? (token-struct-val token) "/* test /* test */ */")
        ))
  (test-case "String literal"
       (let* ([token (tokenize "\"hello\"")])
         (check-equal? (token-struct-type token) 'STRING)
         (check-equal? (token-struct-val token) "hello")))
   (test-case "String literal (Unicode)"
       (let* ([token (tokenize "\"สวัสดี\"")])
         (check-equal? (token-struct-type token) 'STRING)
         (check-equal? (token-struct-val token) "สวัสดี")))
  (test-case "Keywords"
       (for ([keyword keywords])
         (let ([token (tokenize keyword)])
           (check-equal? (token-struct-type token) (string->symbol keyword))
           (check-equal? (token-struct-val token) keyword))))
)

  
   