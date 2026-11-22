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
% expr_of(+List, -Tree)
% Declaratively: Tree is an expression tree over the non-empty list List,
% using every number once, in order.
% Base case: a one-element list [N] has the leaf N as its only tree.
% Recursive case: a list with at least two elements has the tree
% e(Op, L, R) if List splits into a non-empty Left and a non-empty Right,
% L is a tree over Left, R is a tree over Right, and Op is one of + - * /.
% The empty list has no tree (expr_of/2 fails).
expr_of([N], N).
expr_of([A, B|T], e(Op, L, R)) :-
    split_list([A, B|T], Left, Right),
    expr_of(Left, L),
    expr_of(Right, R),
    arith_op(Op).

% split_list(+List, -Left, -Right)
% Declaratively: List is the concatenation of Left and Right, and both
% Left and Right are non-empty.
split_list(List, Left, Right) :-
    append(Left, Right, List),
    Left = [_|_],
    Right = [_|_].

% arith_op(?Op)
% Declaratively: Op is one of the four allowed operators.
arith_op(+).
arith_op(-).
arith_op(*).
arith_op(/).
