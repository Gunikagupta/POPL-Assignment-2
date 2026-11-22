#lang racket/base

;; (my-length lst) -> number
;; Declaratively: the number of top-level elements of lst.
;; Base case: '() gives the accumulator. Step: drop one element, add 1 to acc.
;; Tail-recursive: the recursive call is the last thing done.
(define (my-length lst)
  (let loop ((rest lst) (acc 0))
    (if (null? rest)
        acc
        (loop (cdr rest) (+ acc 1)))))
