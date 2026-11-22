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

(define (reverse-list xs)
  (letrec ((rev
            (lambda (xs acc)
              (if (null? xs)
                  acc
                  (rev (cdr xs)
                       (cons (car xs) acc))))))
    (rev xs '())))

(define (inorder tree)
  (letrec ((walk
            (lambda (tree acc)
              (if (null? tree)
                  acc
                  (let ((left-result
                         (walk (car (cdr tree)) acc)))
                    (let ((with-root
                           (cons (car tree) left-result)))
                      (walk (car (cdr (cdr tree))) with-root)))))))
    (reverse-list (walk tree '()))))

(define (preorder tree)
  (letrec ((walk
            (lambda (tree acc)
              (if (null? tree)
                  acc
                  (let ((with-root
                         (cons (car tree) acc)))
                    (let ((with-left
                           (walk (car (cdr tree)) with-root)))
                      (walk (car (cdr (cdr tree))) with-left)))))))
    (reverse-list (walk tree '()))))


(define (postorder tree)
  (letrec ((walk
            (lambda (tree acc)
              (if (null? tree)
                  acc
                  (let ((with-left
                         (walk (car (cdr tree)) acc)))
                    (let ((with-right
                           (walk (car (cdr (cdr tree))) with-left)))
                      (cons (car tree) with-right)))))))
    (reverse-list (walk tree '()))))

(define (print-inorder tree)
  (display (inorder tree))
  (newline))

(define (print-all-traversals tree)
  (display (inorder tree))
  (newline)
  (display (preorder tree))
  (newline)
  (display (postorder tree))
  (newline))

(define (print-height-and-leaves tree)
  (display (list (height tree) (leaf-count tree)))
  (newline))