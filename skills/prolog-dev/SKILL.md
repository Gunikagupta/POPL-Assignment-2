---
name: prolog-dev
description: Rules for writing, testing and reviewing SWI-Prolog 9.x code for CS F301 Assignment 2 (P1 puzzle, P2 arithmetic equations). Use for any Prolog predicate, test, or review in this repository.
---

# prolog-dev

## 1. Language and version
- SWI-Prolog 9.x. Files are loaded with `swipl -q -f file.pl`, so they hold **definitions only**.
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`. Nothing else (no `clpfd`, no `dcg/basics`, no `strings`).
- Forbidden: `assert/1`, `asserta/1`, `assertz/1`, `retract/1`, `retractall/1`, `b_setval/2`, `nb_setval/2`.
- Forbidden in files: any `:- initialization(...)` directive, any call to `halt/0`, and any top-level directive that runs a goal or prints something on load.
- `:- use_module(library(...))` directives for the allowed libraries are fine.

## 2. Conventions
**Naming**
- Predicates: `snake_case`, descriptive (`count_solutions`, `all_equations`). Variables: `CamelCase`, meaningful (`Solution`, `LeftTree`), never `X1, X2` unless unavoidable.
- Helper predicates get a clear prefix or suffix tied to their parent (`fmt_/2`, `split_list/3`).
- Use `_Name` for intentionally unused variables and `_` for anonymous ones.

**Comments**
- Every predicate has a header comment in this form, directly above its first clause:
  ```prolog
  % clue_holds(+N, +Solution)
  % Declaratively: clue number N is true of the fully filled-in Solution.
  ```
- Use the mode notation `+` (input), `-` (output), `?` (either).
- Every predicate gets a **declarative reading**: one sentence saying what is true when the predicate succeeds, not how it computes it. For recursive predicates, state the base case and the recursive case separately in the comment.

**Style**
- One clause per case. Put the base case first. Keep clauses short.
- Prefer pure relational code (unification, `member/2`, `permutation/2`, `select/3`, `nth1/3`) over procedural tricks.
- Avoid cuts. Use a cut only when it is needed, and say why in a comment.
- Use `format/2` with `~w` to print values without quotes (`c++`, `AI`), `~q` only when quotes are wanted.

## 3. How to run and test
```
swipl -q -f id_q1.pl -g main -t halt
swipl -q -f id_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), write(N), nl" -t halt
swipl -q -f id_q2.pl -g "all_equations([4,2,5,3], Es), print(Es), nl" -t halt
```
- `-t halt` ends the run, so the file never calls `halt/0` itself.
- Test goals are written in separate files under `tests/`, never inside the solution file.
- A test must print nothing on success unless it is checking output. A failing goal under `-g` prints a warning and exits with a non-zero status, so check the exit code.
- Check the exact examples given in the assignment text first, then add edge cases (empty list, one element, no solution, division by zero, inexact division).
- Run with no warnings: `swipl -q -f file.pl -g true -t halt` must print nothing at all (no singleton, discontiguous or syntax warnings).

## 4. Self-review checklist (apply before every answer)
1. Does the file contain only definitions? No `initialization`, no `halt`, no directives that run goals, no output on load.
2. Are only the allowed libraries used, and no forbidden database or global-variable predicates?
3. Does each predicate have a mode comment and a declarative reading?
4. Are there singleton variable warnings? Are clauses of the same predicate contiguous?
5. Is every atom exactly as the spec says? (`'Alex'`, `'c++'`, `'AI'` are quoted; `web`, `data`, `python` are not.)
6. Is the data type correct: string vs atom vs code list? (Check the spec for which one a predicate must return.)
7. Does the predicate terminate on all inputs, including the empty list and failing cases? Is recursion on a shrinking argument?
8. Is negation (`\+`) only applied to goals whose variables are already bound?
9. Does the predicate fail cleanly (no error, no loop) when there is no answer, if the spec says so?
10. Does it print only what the spec asks for?
11. Was the code actually run with the given examples, and was the result compared against the expected output?
12. Does it meet the "one prompt = one unit" rule, i.e. does this answer contain exactly the one predicate (and its helpers) that was asked for?

## 5. Known AI failure modes for Prolog
- **Cuts and negation as failure**: adding `!` that cuts away valid solutions, or using `\+` on a goal with unbound variables (so it tests "no solution exists" instead of "this one is false"). Order of goals matters for `\+`.
- **Singleton variables and typos**: variable names that appear once, causing warnings and wrong logic. Mixing up `Lang` and `Language` in a clause.
- **Strings vs atoms vs code lists**: in SWI-Prolog 7+, `"abc"` is a string object, not a code list or atom. Using `atom_codes` or `atom_concat` where `string_concat`, `format(string(S), ...)` or `with_output_to(string(S), ...)` is needed. Always check which type the spec requires.
- **Quoting**: forgetting quotes on `'Alex'`, `'c++'`, `'AI'`, or adding quotes that change the atom (`AI` without quotes is a variable!). Printing with `~q` or `print/1` when `~w` is wanted.
- **Infinite recursion on left recursion**: a clause like `expr(E) :- expr(L), ...` loops. Make sure each recursive call works on a smaller list or structure.
- **`is` vs `=`**: using `X = A+B` instead of `X is A+B`, or `is` with an unbound right-hand side (instantiation error).
- **Division**: `/` in SWI-Prolog gives a float when the result is inexact. Exact division must be checked explicitly (`B =\= 0, A mod B =:= 0, V is A // B`).
- **Arithmetic comparison**: `=` vs `==` vs `=:=`; comparing numbers with `==` that differ in type (`2` vs `2.0`).
- **Duplicates and ordering**: `findall/3` keeps duplicates; `sort/2` removes them and orders by standard order, while `msort/2` keeps them and `sort/4` can be used for other orders. `bagof/3` and `setof/3` fail on no solutions and group by free variables unless `^` is used.
- **Directives in files**: adding `:- initialization(main).`, `:- main.`, or `halt.` at the end of the file. These break the grader.
- **Extra output**: leaving debug `write/1` or `print_message` calls, or printing a trailing result like `true.`
- **Unavailable libraries**: using `clpfd`, `dicts`, `assoc` or `solution_sequences` when they are not on the allowed list, or using `maplist` with `yall` lambdas whose free variables are not shared as intended (`\X^..`, `/` syntax).
- **Hard-coding**: writing the answer into the file instead of deriving it from the clues.
- **Non-exhaustive tests**: only testing the happy path, and not checking that failing cases fail.
- **Claiming it works without running it**: always run the code and quote the real output.