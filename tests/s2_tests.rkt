;; S2 tests. No #lang line: this file is appended to the solution, the same way the grader does it.
;; Run from the repo root:
;;   cat code/G39_q4.rkt tests/s2_tests.rkt > /tmp/s2_run.rkt && racket /tmp/s2_run.rkt
;; (Test code may use helpers like equal? and parameterize; the solution file does not.)

(define (check name actual expected)
  (display (if (equal? actual expected) "PASS " "FAIL "))
  (display name)
  (newline))

;; Runs print-insert-result with the given text as standard input and returns what it printed.
(define (run-with-input text)
  (let ((out (open-output-string)))
    (parameterize ((current-input-port (open-input-string text))
                   (current-output-port out))
      (print-insert-result))
    (get-output-string out)))

;; The four examples from the spec, through standard input
(check "spec 1" (run-with-input "42 ((1 2) (3 4 5) (6) ()) 3") "((42 1 2) (3 4 5) (42 6) (42))\n")
(check "spec 2" (run-with-input "0 (((1) 2) (3) ((4 5 6) ())) 3") "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
(check "spec 3" (run-with-input "7 () 3") "(7)\n")
(check "spec 4" (run-with-input "7 () 0") "()\n")

;; Edge cases on insert-if-short directly
(check "n = 0 never inserts" (insert-if-short 'x '((1) (2 3) ()) 0) '((1) (2 3) ()))
(check "length measured before insertion" (insert-if-short 'x '(1 2) 3) '(x 1 2))
(check "length equal to n is not short" (insert-if-short 'x '(1 2 3) 3) '(1 2 3))
(check "symbols as atoms" (insert-if-short 'z '(a (b c) d) 3) '(a (z b c) d))
(check "make-inserter with another test"
       ((make-inserter 'q (lambda (len) (= len 2))) '((1 2) (3) (4 5)))
       '((q 1 2) (3) (q 4 5)))

;; Nesting depth 100: (((...(5)...))) with 100 levels
(define (nest d) (if (= d 0) '(5) (list (nest (- d 1)))))
(define (nest-expected d) (if (= d 0) '(x 5) (list 'x (nest-expected (- d 1)))))
(check "nesting depth 100" (insert-if-short 'x (nest 100) 3) (nest-expected 100))

;; 10,000-element flat list: length 10000 is not < 5, so it is unchanged
(define (range-list k) (let loop ((i k) (acc '())) (if (= i 0) acc (loop (- i 1) (cons i acc)))))
(define big (range-list 10000))
(check "10,000 elements, not short" (insert-if-short 'x big 5) big)
(check "10,000 elements, short" (insert-if-short 'x big 10001) (cons 'x big))

;; 10,000 short sublists
(define (many-sublists k) (let loop ((i k) (acc '())) (if (= i 0) acc (loop (- i 1) (cons (list i) acc)))))
(define (many-expected k) (let loop ((i k) (acc '())) (if (= i 0) acc (loop (- i 1) (cons (list 'x i) acc)))))
(check "10,000 sublists" (insert-if-short 'x (many-sublists 10000) 2) (many-expected 10000))

;; Speed: the big cases together should take well under a second
(define (timed-ms thunk)
  (let ((start (current-inexact-milliseconds)))
    (thunk)
    (- (current-inexact-milliseconds) start)))
(define elapsed
  (timed-ms (lambda ()
              (insert-if-short 'x big 10001)
              (insert-if-short 'x (many-sublists 10000) 2)
              (insert-if-short 'x (nest 100) 3))))
(check "runs quickly (< 1000 ms)" (< elapsed 1000) #t)
