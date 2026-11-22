---
name: scheme-dev
description: Rules for writing, testing and reviewing Racket 8.x code (#lang racket/base, restricted built-ins) for CS F301 Assignment 2 (S1 tree traversals, S2 conditional nested insert). Use for any Scheme function, test, or review in this repository.
---

# scheme-dev

## 1. Language and version
- Racket 8.x. Every solution file starts with `#lang racket/base` and nothing else from the language is assumed.
- Files contain **definitions only**. No top-level calls, no top-level `display`, nothing printed when the file is loaded. The grader appends its own calls to the end of the file.
- No `require`, no `provide`, no `module` forms.

## 2. Allowed built-ins (and nothing else)
- **Binding and control:** `define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (always with an `else` clause), `and`, `or`, `not`, `begin`, `quote` (written `'`).
- **Pairs and lists:** `cons`, `car`, `cdr`, `list`, every `c[ad]{2,4}r` composition (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, ...), `null?`, `pair?`, `eq?`, `assq`, `assoc`.
- **Arithmetic and comparison:** `+ - * < > <= >= =`, `max`.
- **Output:** `display`, `newline`.
- **Input:** `read`, only in S2 (`print-insert-result`).
- Internal `define`s inside function bodies are fine (they are `define`).

## 3. Forbidden
- Mutation: `set!` and its relatives (`set-car!`, `set-cdr!`, `begin0` tricks with state, boxes).
- Data types: vectors, hash tables, strings (including string literals such as `" "` or `"\n"`), chars.
- Loops: `do`, `for` and all `for/...` forms.
- List functions: `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`. Also anything not on the allowed list, for example `equal?`, `eqv?`, `zero?`, `add1`, `sub1`, `min`, `abs`, `even?`, `number?`, `symbol?`, `list?`, `apply`, `foldl`, `foldr`, `when`, `unless`, `case`, `let-values`, `error`, `void`, `printf`, `format`, `write`, `print`.
- If you need a forbidden function, write your own helper from allowed pieces (`my-length`, `my-map`, `my-reverse`, `my-append`).

## 4. Conventions
**Naming and comments**
- Names are lowercase with hyphens (`print-all-traversals`, `my-reverse`); predicates end in `?`; helpers go next to the function they serve and are named after it (`inorder-acc`).
- Every function has a comment directly above it:
  ```racket
  ;; (my-length lst) -> number
  ;; Declaratively: the number of top-level elements of lst.
  ;; Base case: '() has length 0. Step: (cons x rest) has length 1 + length of rest.
  ```
- State a **recursive reading** of each function in that comment: the base case and the step, in words.

**Recursion and state**
- Pass all state through function arguments. No global state, no mutation.
- Prefer **tail recursion with an accumulator** where it is natural (`my-length`, `my-reverse`, traversals that build a list by consing and reversing at the end, or by traversing right-to-left so `cons` builds the list in order).
- Use a named `let` or an internal helper for the accumulator, so the public function keeps the signature in the spec.
- Tree shape: `'()` or `(value left right)`. Take parts with `car`, `cadr`, `caddr`. Always test `(null? tree)` first.
- Treat anything that is not a pair as an atom: `(and (not (pair? x)) (not (null? x)))`. There is no `atom?` in Racket.
- Write the empty list as `'()`. A bare `()` is an error in Racket.
- Use `=` for numbers. Use `eq?` only for symbols and `'()`.

**Output**
- Print a list by calling `(display lst)` on the list value, then `(newline)`. This prints `(1 2 3)` and `()` correctly with no string literals.
- Each print function ends its output with exactly one newline per line printed.

## 5. How to run and test
- Run a solution file: `racket id_q3.rkt` (prints nothing) and `racket id_q4.rkt` (prints nothing).
- The grader appends calls to the file, so test files in `tests/` contain only the calls (no `#lang` line). To run them:
  ```
  cat code/id_q3.rkt tests/s1_calls.txt > /tmp/s1_run.rkt && racket /tmp/s1_run.rkt
  echo "42 ((1 2) (3 4 5) (6) ()) 3" | { cat code/id_q4.rkt tests/s2_call.txt > /tmp/s2_run.rkt; racket /tmp/s2_run.rkt; }
  ```
  (For S2, `tests/s2_call.txt` holds the single line `(print-insert-result)`; write the file first and pipe the input into `racket`.)
- Compare the real output with the examples in the assignment, character by character.
- Test edge cases: empty tree/list, single node, deep nesting (depth 100), long lists (10,000 elements), `n = 0`.

## 6. Self-review checklist (apply before every answer)
1. First line is `#lang racket/base`. No `require`, `provide`, or other forms.
2. Only definitions at top level. Nothing prints on load; no top-level calls.
3. Every identifier used is on the allowed list or defined in the file. Scan for `length`, `append`, `reverse`, `map`, `filter`, `member`, `list-ref`, `equal?`, `zero?`, `add1`, `sub1`, `else`-less `cond`.
4. Every `cond` ends with an `else` clause.
5. No `set!`, vectors, hashes, strings (check string literals), or loops.
6. The empty list is written `'()`, never `()`.
7. Parentheses balance, and every function returns a value (not a printed side effect) unless the spec says it prints.
8. Recursion has a base case and shrinks its argument. Accumulators are initialised correctly.
9. Output format matches exactly: one line per print, parentheses and spaces as `display` gives them, a final newline.
10. Behaviour was checked on the spec examples (t1, t2, t3, empty tree; the four S2 examples) by actually running the code.
11. The answer holds exactly the one function (plus helpers) that was asked for.
12. For S2: only one definition of `insert-if-short` in the final file, and lengths are measured on the original list before insertion.

## 7. Known AI failure modes for Scheme/Racket
- **Using forbidden built-ins**: `length`, `append`, `reverse`, `map`, `filter`, `member`, `list-ref`, `list-tail`, `apply`, `foldl`, `equal?`, `zero?`, `add1`, `sub1`, `for`, `when`, `case`, or `printf` slip in out of habit. Replace them with allowed pieces or your own helper.
- **`cond` without `else`**: the last case falls through and returns `#<void>`, which then prints as nothing or crashes later.
- **Printing on load**: top-level `(display ...)`, `(print-inorder t1)` or test calls left in the solution file.
- **Wrong display of `'()`**: writing `(display '())` through `write`, `print` or `printf` (prints `'()` in print mode), or building a string such as `"()"`. Use `display` on the list value itself.
- **Bare `()`**: `()` without a quote is an error (`#%app: missing procedure expression`). Use `'()`.
- **String literals**: `(display " ")` or `(display "\n")` break the no-strings rule. Use `(newline)` and `display` of list values.
- **Mutation**: using `set!` to accumulate output or counts.
- **Wrong tree access**: `cadr` for the right subtree (it is the left), or missing the `(null? tree)` check, so `car` is applied to `'()`.
- **Mixed-up traversal order**: producing preorder where inorder is wanted, or reversed output from an accumulator that was never reversed.
- **Reverse accumulators**: consing onto an accumulator gives a reversed list. Either traverse right-to-left or call your own `my-reverse` at the end.
- **Measuring length after insertion** (S2): inserting `x` first and then testing the length gives the wrong answer. Measure on the original list.
- **Treating `'()` as an atom** (S2): `'()` is a list of length 0 and gets `x` inserted when `0 < n`.
- **Atom test errors**: using `atom?` (does not exist) or `list?`/`symbol?`/`number?` (not allowed). Use `pair?` and `null?`.
- **`eq?` on numbers**: unreliable for large or non-fixnum numbers; use `=`.
- **Unbalanced or misplaced parentheses**, and `define` forms accidentally evaluated at the wrong nesting level.
- **Missing tail calls**: deep non-tail recursion works in Racket but is slow and memory-hungry for 10,000-element lists. Use an accumulator.
- **Claiming it works without running it**: always run the code with `racket` and quote the real output.