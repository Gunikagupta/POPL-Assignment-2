#lang racket/base


(define (height tree)
  (if (null? tree)
      0
      (+ 1
         (max (height (car (cdr tree)))
              (height (car (cdr (cdr tree))))))))