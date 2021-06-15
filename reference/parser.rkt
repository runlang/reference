#lang racket/base

(require "lexer.rkt" "grammar.rkt"
         syntax/parse)

(module+ test
  (require rackunit))


(define (parse-input path i)
  (let [(tokenizer (make-tokenizer i path))]
    (parse tokenizer)))

(provide parse-input)