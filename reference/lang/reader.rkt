#lang racket

(require "../lexer.rkt" "../parser.rkt")

(define (read-syntax path port)
  (define parse-tree (parse-input path port))
   #`(module basic-mod racket/base
       #,parse-tree))

(define (get-info port src-mod src-line src-col src-pos)
    (define (handle-query key default)
      (case key
        [(color-lexer)
         (dynamic-require 'runlang/reference/colorer 'run-colorer)]
        [else default]))
    handle-query)

(provide read-syntax get-info)
