#lang racket/base

(require racket/list syntax/parse "parser.rkt")

(struct ctx (block-stack) #:transparent)

(define (new-ctx)
  (ctx (list (new-block #f))))

(define (push-block-stack c block)
  (struct-copy ctx c [block-stack (cons block (ctx-block-stack c))]))

(struct block (label [undo-exprs #:mutable]) #:transparent)

(define (new-block label)
  (block label '()))

(define (interpret stx)
  (syntax-parse stx
    [({~literal program} exprs ...)
     (let ([ctx (new-ctx)])
       (for ([expr-stx (syntax->list #'(exprs ...))])
         (interpret-expr expr-stx ctx)))]))

(define (interpret-expr stx ctx)
  (syntax-parse stx
    #:datum-literals (block label call concurrent if literal boolean to-undo undo-to)
    [(block exprs ...)
     (for ([expr-stx (syntax->list #'(exprs ...))])
                 (interpret-expr expr-stx ctx))]
    [(label name exprs ...)
     (let ([new-ctx (push-block-stack ctx (new-block (syntax-e #'name)))])
       (for ([expr-stx (syntax->list #'(exprs ...))])
                   (interpret-expr expr-stx new-ctx)))]
    [(call name args ...)
     (println (string-append "call " (syntax-e #'name)))]
    [(concurrent expr ...)
     (let* ([threads (map (lambda (e) (thread (lambda () (interpret-expr e ctx))))
                          (syntax->list #'(expr ...)))]
            [dead-evts (map thread-dead-evt threads)])
       (wait-for-threads-to-complete dead-evts))]
    [(if cond-expr then-expr (~optional else-expr))
     (if (interpret-expr #'cond-expr ctx) (interpret-expr #'then-expr ctx) (interpret-expr #'else-expr ctx))]
    [(to-undo expr)
     (let* ([block (first (ctx-block-stack ctx))]
            [undo-exprs (block-undo-exprs block)])
       (set-block-undo-exprs! block (cons #'expr undo-exprs))
       )]
    [(undo-to name)
     (for ([block (ctx-block-stack ctx)]
           #:final (eq? (block-label block) (syntax-e #'name)))
       (let ([undo-exprs (block-undo-exprs block)])
         (for ([undo-expr undo-exprs])
           (interpret-expr undo-expr ctx))))]
    [(literal (boolean "true"))
     #t]
    [(literal (boolean "false"))
     #f]
    [(literal (_ value))
     (syntax-e #'value)]
    [v
     (println #'v)]))

(provide interpret)

(define (wait-for-threads-to-complete dead-evts)
  (if (empty? dead-evts) #t
      (wait-for-threads-to-complete (remove (apply sync dead-evts) dead-evts))))