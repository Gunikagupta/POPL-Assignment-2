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

;; (make-inserter x len-ok?) -> (list -> list)
;; Declaratively: a function that, given a list, processes every sublist
;; (at any depth) the same way, then puts x at the front if (len-ok? original-length).
;; An element is a list when it is a pair or '(); otherwise it is an atom and is kept.
(define (make-inserter x len-ok?)
  (letrec ((insert
            (lambda (lst)
              (let ((processed
                     (my-map (lambda (e)
                               (if (or (pair? e) (null? e))
                                   (insert e)
                                   e))
                             lst)))
                (if (len-ok? (my-length lst))
                    (cons x processed)
                    processed)))))
    insert))

;; (insert-if-short x lst n) -> list
;; Declaratively: make-inserter with the test "length < n", applied to lst.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))
