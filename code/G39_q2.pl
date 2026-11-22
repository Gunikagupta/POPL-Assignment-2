% eval(+Expr, -Value)
% Declaratively: Value is the integer value of the expression term Expr.
% Base case: an integer evaluates to itself.
% Recursive case: e(Op,L,R) has value V if L and R both evaluate
% (to VL and VR) and applying Op to VL and VR is defined and gives V.
% If any division inside the tree is inexact or has a zero divisor,
% eval/2 fails.
eval(N, N) :-
    integer(N).
eval(e(Op, L, R), V) :-
    eval(L, VL),
    eval(R, VR),
    apply_op(Op, VL, VR, V).

% apply_op(+Op, +A, +B, -V)
% Declaratively: V is the result of applying operator Op to A and B.
% Division succeeds only when B is non-zero and A is exactly divisible
% by B; otherwise the clause fails.
apply_op(+, A, B, V) :- V is A + B.
apply_op(-, A, B, V) :- V is A - B.
apply_op(*, A, B, V) :- V is A * B.
apply_op(/, A, B, V) :-
    B =\= 0,
    A mod B =:= 0,
    V is A // B.
