# P1 Report: Department Assignment Puzzle, Reloaded

## 1. Approach

- `solution/1` generates every candidate assignment. It builds four terms `p(Name, Dept, Lang, Project)` and uses `permutation/2` once per attribute, so each value of each attribute is used exactly once. That gives 24 × 24 × 24 = **13,824** candidates.
- Each clue is its own clause `clue(N, Solution)` that succeeds exactly when clue N holds in a fully filled-in solution.
- `holds_all(Active, Solution)` checks that every clue number in the list `Active` holds.
- `main/0` takes the first candidate that satisfies clues 1 to 8 (generate and test, nothing hard-coded) and prints it.
- `count_solutions(Active, N)` uses `findall/3` to collect every candidate that satisfies exactly the clues in `Active` (the others are ignored) and counts them.

## 2. P1.b: the value of N for clues 1 to 8

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

**N = 3.** The three solutions are:

| | Alex | Ben | Carla | Dana |
|---|---|---|---|---|
| 1 | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| 2 | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| 3 | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

### What this tells us about the puzzle

- The puzzle as written is **under-constrained**. A good logic puzzle has exactly one solution, and clues 1 to 8 leave three, so they do not determine the answer.
- The clues do pin some things down completely. Ben is `[development, javascript, web]` in all three solutions. The unresolved part is how the other three friends share the remaining values.
- `count_solutions` also shows how much each clue narrows the search. With no clues N = 13,824. With clue 1 alone N = 7,776. With clues 3 and 5 N = 1,152. With clues 4, 7 and 8 N = 208. With all eight, N = 3.
- This is why `main` can print "one solution" for P1.a, but the output is only one of three valid answers. It prints the first one the search finds, which is solution 1.

## 3. P1.c: the repair (clue 9)

```prolog
% CLUE 9: The friend who prefers the embedded project works in the design department.
clue(9, Solution) :-
    member(p(_, Dept, _, embedded), Solution),
    Dept == design.
```

The clue names no friend and finds one only through an attribute value (the project `embedded`), as clue 5 does.

| Solution | Friend who prefers embedded | Department | Clue 9 |
|---|---|---|---|
| 1 | Dana | testing | false |
| 2 | Alex | design | **true** |
| 3 | Alex | testing | false |

Clue 9 is true in solution 2 only, so it is the one we keep:

```
Alex = [design, java, embedded]
Ben = [development, javascript, web]
Carla = [testing, python, AI]
Dana = [research, c++, data]
```

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

**N = 1**, so the puzzle now has a unique solution.

## 4. Notes

- Clue 9 is not the only possible repair. Any clue that is true in exactly one of the three solutions works. For example, "The friend who prefers the AI project likes Python" is also true in solution 2 only.
- `main/0` still prints solution 1, because it uses clues 1 to 8 only (as P1.a asks). It does not print the unique solution that survives clue 9.
- Tests are in `tests/p1_tests.pl` (26 tests, run with `swipl -q -f tests/p1_tests.pl -g run_p1_tests -t halt`).