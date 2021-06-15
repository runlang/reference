#lang racket/base

(require "parser.rkt" "interpreter.rkt")

(module+ main
  (require racket/cmdline)
  (command-line
    #:program "runlang"
    #:once-each
    #:args (filename)

    (interpret (parse-input filename (open-input-file filename)))
    (exit)))