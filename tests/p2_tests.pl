% Tests for P2 (G39_q2.pl). Definitions only: run from the command line with
%   swipl -q code/G39_q2.pl tests/p2_tests.pl -g run_p2_tests -t halt

% p2_test(+Name, +Goal)
% Declaratively: Goal is a check that must succeed for the P2 code to be correct.
% Checks that expect failure are written with \+.

% --- all_equations/2: examples from the spec ---
p2_test(all_4253,
        all_equations([4,2,5,3], ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"])).
p2_test(all_234_none,     all_equations([2,3,4], [])).
p2_test(all_248,          all_equations([2,4,8], ["2*4=8"])).

% --- edge cases: length 0 and 1 ---
p2_test(all_empty,        all_equations([], [])).
p2_test(all_single,       all_equations([5], [])).

% --- count_equations/2 ---
p2_test(count_4253,       count_equations([4,2,5,3], 7)).
p2_test(count_234,        count_equations([2,3,4], 0)).
p2_test(count_empty,      count_equations([], 0)).

% --- generate_equation/2 ---
p2_test(gen_4253_valid,
        ( generate_equation([4,2,5,3], E),
          member(E, ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                     "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]) )).
p2_test(gen_4253_is_string,
        ( generate_equation([4,2,5,3], E), string(E), \+ atom(E) )).
p2_test(gen_248,          ( generate_equation([2,4,8], E), E == "2*4=8" )).
p2_test(gen_234_fails,    \+ generate_equation([2,3,4], _)).
p2_test(gen_empty_fails,  \+ generate_equation([], _)).
p2_test(gen_single_fails, \+ generate_equation([5], _)).

% --- division: inexact (7/2 is 3.5, so "7/2=3" must NOT be produced) ---
p2_test(eval_inexact,        \+ eval(e(/,7,2), _)).
p2_test(eval_inexact_nested, \+ eval(e(+,e(/,7,2),1), _)).
p2_test(inexact_no_equation, all_equations([7,2,3], [])).

% --- division: by zero ---
p2_test(eval_zero_divisor, \+ eval(e(/,5,0), _)).
p2_test(eval_zero_nested,  \+ eval(e(+,1,e(/,4,e(-,3,3))), _)).
p2_test(zero_no_division,
        ( all_equations([0,0,0], Es),
          \+ ( member(E, Es), sub_string(E, _, _, _, "/") ) )).
p2_test(zero_count,        count_equations([0,0,0], 6)).

% --- eval/2 basics ---
p2_test(eval_exact,    ( eval(e(/,8,e(-,5,3)), V), V =:= 4 )).
p2_test(eval_negative, ( eval(e(-,3,5), V), V =:= -2 )).

% --- fmt/2: the parenthesisation examples from the spec ---
p2_test(fmt_left_assoc,  fmt(e(*,e(/,8,4),2), "8/4*2")).
p2_test(fmt_right_paren, fmt(e(/,8,e(*,4,2)), "8/(4*2)")).
p2_test(fmt_minus_left,  fmt(e(-,e(-,1,2),3), "1-2-3")).
p2_test(fmt_minus_right, fmt(e(-,1,e(-,2,3)), "1-(2-3)")).
p2_test(fmt_plus_right,  fmt(e(+,1,e(+,2,3)), "1+(2+3)")).
p2_test(fmt_plus_left,   fmt(e(+,e(+,1,2),3), "1+2+3")).
p2_test(fmt_low_in_high, fmt(e(*,e(+,4,2),3), "(4+2)*3")).
p2_test(fmt_high_in_low, fmt(e(+,4,e(*,2,3)), "4+2*3")).

% test_passes(+Goal)
% Declaratively: Goal succeeds at least once without raising an error.
% An error is reported on one line and counts as a failure.
test_passes(Goal) :-
    catch(once(Goal), Error,
          ( format("ERROR: ~q~n", [Error]), fail )).

% run_p2_tests
% Declaratively: every p2_test/2 goal passes. Prints nothing when all pass;
% otherwise prints one "FAIL: Name" line per failing test and fails.
run_p2_tests :-
    findall(Name, ( p2_test(Name, Goal), \+ test_passes(Goal) ), Failed),
    (   Failed == []
    ->  true
    ;   forall(member(F, Failed), format("FAIL: ~w~n", [F])),
        fail
    ).
