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

;; (my-reverse lst) -> list
;; Declaratively: the elements of lst in the opposite order.
;; Base case: '() gives the accumulator. Step: cons the head onto acc.
(define (my-reverse lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        acc
        (loop (cdr rest) (cons (car rest) acc)))))

;; (my-map f lst) -> list
;; Declaratively: the list of (f e) for each top-level element e of lst, in order.
;; Base case: '() gives (my-reverse acc). Step: cons (f head) onto acc.
;; Tail-recursive with an accumulator, reversed once at the end.
(define (my-map f lst)
  (let loop ((rest lst) (acc '()))
    (if (null? rest)
        (my-reverse acc)
        (loop (cdr rest) (cons (f (car rest)) acc)))))

;; (insert-if-short x lst n) -> list
;; Declaratively: lst with every sublist (at any depth) processed the same way,
;; and x put at the front if lst's ORIGINAL length is < n.
;; An element is a list when it is a pair or '(); otherwise it is an atom and is kept.
(define (insert-if-short x lst n)
  (let ((processed
         (my-map (lambda (e)
                   (if (or (pair? e) (null? e))
                       (insert-if-short x e n)
                       e))
                 lst)))
    (if (< (my-length lst) n)
        (cons x processed)
        processed)))
