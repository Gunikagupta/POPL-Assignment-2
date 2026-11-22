; To run S1 tests:
; cat code/G39_q3.rkt tests/s1_tests.rkt > /tmp/s1_run.rkt && racket /tmp/s1_run.rkt



(define t1
  '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))

(define t2
  '(1 () (2 () (3 () ()))))

(define t3
  '(a (b () ()) (c () ())))

(define t4 '())

(print-inorder t1)
(print-all-traversals t1)
(print-height-and-leaves t1)

(print-all-traversals t2)
(print-height-and-leaves t2)

(print-all-traversals t3)
(print-height-and-leaves t3)

(print-all-traversals t4)
(print-height-and-leaves t4)