#lang racket/base


(define (height tree)
  (if (null? tree)
      0
      (+ 1
         (max (height (car (cdr tree)))
              (height (car (cdr (cdr tree))))))))


(define (leaf-count tree)
  (if (null? tree)
      0
      (if (and (null? (car (cdr tree)))
               (null? (car (cdr (cdr tree)))))
          1
          (+ (leaf-count (car (cdr tree)))
             (leaf-count (car (cdr (cdr tree))))))))