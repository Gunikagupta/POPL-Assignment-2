% tests/p1_tests.pl -- tests for P1 (department assignment puzzle).
%
% 
%   swipl -q -f tests/p1_tests.pl -g run_p1_tests -t halt
%
% Every test prints "PASS <name>" or "FAIL <name>". If any test fails,
% run_p1_tests prints a summary and then fails, so swipl reports a failed goal.
% This file never calls halt/0 and uses no initialization directive.

:- ensure_loaded('../code/G8_q1.pl').

% ---------------------------------------------------------------------------
% Test runner
% ---------------------------------------------------------------------------

% run_one(+Name, +Goal, -Result)
% Declaratively: Result is pass if Goal succeeds (without raising an error),
% otherwise fail; the verdict is printed as one line "PASS Name" / "FAIL Name".
run_one(Name, Goal, Result) :-
    (   catch(Goal, _, fail)
    ->  Result = pass, format("PASS ~w~n", [Name])
    ;   Result = fail, format("FAIL ~w~n", [Name])
    ).

% run_p1_tests
% Declaratively: runs every test_case/2 in order, prints a verdict per test and
% a summary line; it succeeds only if every test passed.
run_p1_tests :-
    findall(Result,
            ( test_case(Name, Goal), run_one(Name, Goal, Result) ),
            Results),
    include(==(fail), Results, Failures),
    length(Results, Total),
    length(Failures, NumFailed),
    (   NumFailed =:= 0
    ->  format("ALL ~w TESTS PASSED~n", [Total])
    ;   format("~w OF ~w TESTS FAILED~n", [NumFailed, Total]),
        fail
    ).

% ---------------------------------------------------------------------------
% Sample solutions (fully filled in) used by the clue tests
% ---------------------------------------------------------------------------

% The three solutions of clues 1-8.
sol_a([p('Alex',design,java,'AI'),        p('Ben',development,javascript,web),
       p('Carla',research,'c++',data),    p('Dana',testing,python,embedded)]).
sol_b([p('Alex',design,java,embedded),    p('Ben',development,javascript,web),
       p('Carla',testing,python,'AI'),    p('Dana',research,'c++',data)]).
sol_c([p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
       p('Carla',design,java,'AI'),       p('Dana',research,'c++',data)]).

% holds/2 and fails/2 are interleaved clue by clue, so declare them discontiguous.
:- discontiguous holds/2, fails/2.

% One solution where clue N holds and one where it fails (for N = 1..8).
% Each "bad" solution is a valid assignment that breaks exactly clue N.
holds(1, [p('Alex',design,java,'AI'),     p('Ben',testing,python,web),
          p('Carla',development,'c++',embedded), p('Dana',research,javascript,data)]).
fails(1, [p('Alex',research,java,'AI'),   p('Ben',testing,python,web),
          p('Carla',development,'c++',embedded), p('Dana',design,javascript,data)]).

holds(2, [p('Alex',design,java,web),      p('Ben',testing,python,data),
          p('Carla',development,'c++',embedded), p('Dana',research,javascript,'AI')]).
fails(2, [p('Alex',design,'c++',web),     p('Ben',testing,python,data),
          p('Carla',development,java,embedded),  p('Dana',research,javascript,'AI')]).

holds(3, [p('Alex',design,java,web),      p('Ben',testing,python,data),
          p('Carla',development,'c++',embedded), p('Dana',research,javascript,'AI')]).
fails(3, [p('Alex',design,java,web),      p('Ben',testing,javascript,data),
          p('Carla',development,'c++',embedded), p('Dana',research,python,'AI')]).

holds(4, [p('Alex',design,java,data),     p('Ben',development,python,web),
          p('Carla',testing,'c++',embedded),     p('Dana',research,javascript,'AI')]).
fails(4, [p('Alex',design,java,data),     p('Ben',testing,python,web),
          p('Carla',development,'c++',embedded), p('Dana',research,javascript,'AI')]).

holds(5, [p('Alex',design,java,data),     p('Ben',development,python,web),
          p('Carla',testing,'c++',embedded),     p('Dana',research,javascript,'AI')]).
fails(5, [p('Alex',research,java,data),   p('Ben',development,python,web),
          p('Carla',testing,'c++',embedded),     p('Dana',design,javascript,'AI')]).

holds(6, [p('Alex',design,java,data),     p('Ben',development,python,web),
          p('Carla',testing,'c++','AI'),         p('Dana',research,javascript,embedded)]).
fails(6, [p('Alex',design,java,data),     p('Ben',testing,python,web),
          p('Carla',research,'c++',embedded),    p('Dana',development,javascript,'AI')]).

holds(7, [p('Alex',design,java,data),     p('Ben',development,python,web),
          p('Carla',research,'c++',embedded),    p('Dana',testing,javascript,'AI')]).
fails(7, [p('Alex',research,python,data), p('Ben',development,'c++',web),
          p('Carla',testing,javascript,embedded), p('Dana',design,java,'AI')]).

holds(8, [p('Alex',research,python,data), p('Ben',development,java,web),
          p('Carla',design,'c++',embedded),      p('Dana',testing,javascript,'AI')]).
fails(8, [p('Alex',research,javascript,data), p('Ben',development,java,web),
          p('Carla',design,'c++',embedded),      p('Dana',testing,python,'AI')]).

% ---------------------------------------------------------------------------
% Test cases: test_case(Name, Goal)
% ---------------------------------------------------------------------------

% One passing and one failing solution for each clue 1..8.
test_case(Name, clue(N, S)) :-
    between(1, 8, N), holds(N, S),
    format(atom(Name), "clue ~w holds on a good solution", [N]).
test_case(Name, \+ clue(N, S)) :-
    between(1, 8, N), fails(N, S),
    format(atom(Name), "clue ~w fails on a bad solution", [N]).

% The three solutions of clues 1-8 really satisfy all eight clues.
test_case("solution a satisfies clues 1-8", holds_all([1,2,3,4,5,6,7,8], S)) :- sol_a(S).
test_case("solution b satisfies clues 1-8", holds_all([1,2,3,4,5,6,7,8], S)) :- sol_b(S).
test_case("solution c satisfies clues 1-8", holds_all([1,2,3,4,5,6,7,8], S)) :- sol_c(S).

% Counting (P1.b and P1.c).
test_case("candidate space has 13824 solutions (no clues)",
          ( count_solutions([], N), N =:= 13824 )).
test_case("count_solutions clues 1-8 gives N = 3",
          ( count_solutions([1,2,3,4,5,6,7,8], N), N =:= 3 )).
test_case("count_solutions clues 1-9 gives N = 1",
          ( count_solutions([1,2,3,4,5,6,7,8,9], N), N =:= 1 )).
test_case("clue 9 holds in exactly one of the 3 solutions of clues 1-8",
          ( aggregate_all(count,
                          ( solution(S), holds_all([1,2,3,4,5,6,7,8], S), clue(9, S) ),
                          Holds),
            aggregate_all(count,
                          ( solution(S), holds_all([1,2,3,4,5,6,7,8], S) ),
                          Total),
            Holds =:= 1, Total =:= 3 )).
test_case("clue 9 is true in solution b and false in solutions a and c",
          ( sol_a(A), sol_b(B), sol_c(C),
            \+ clue(9, A), clue(9, B), \+ clue(9, C) )).

% main/0 prints one solution as four lines "Name = [Dept, Lang, Project]".
test_case("main prints four lines in the required layout",
          ( with_output_to(string(Out), main),
            split_string(Out, "\n", "", Parts),
            Parts = [L1, L2, L3, L4, ""],
            sub_string(L1, 0, _, _, "Alex = ["),
            sub_string(L2, 0, _, _, "Ben = ["),
            sub_string(L3, 0, _, _, "Carla = ["),
            sub_string(L4, 0, _, _, "Dana = [") )).
test_case("main prints a solution that satisfies clues 1-8",
          ( with_output_to(string(Out), main),
            split_string(Out, "\n", "", [L1, L2, L3, L4, _]),
            sol_from_lines([L1, L2, L3, L4], S),
            holds_all([1,2,3,4,5,6,7,8], S) )).

% sol_from_lines(+Lines, -Solution)
% Declaratively: Solution is the list of p(Name, Dept, Lang, Project) terms
% described by the four printed lines, with values converted back to atoms
% ('c++' and 'AI' keep their spelling; project/language atoms are unquoted text).
sol_from_lines([], []).
sol_from_lines([Line|Lines], [p(Name, Dept, Lang, Project)|Rest]) :-
    split_string(Line, "=", " ", [NameStr, ListStr]),
    split_string(ListStr, ",[]", " []", [DeptStr, LangStr, ProjStr]),
    maplist([S, A]>>atom_string(A, S), [NameStr, DeptStr, LangStr, ProjStr],
            [Name, Dept, Lang, Project]),
    sol_from_lines(Lines, Rest).