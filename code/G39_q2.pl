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

% expr_val(+List, -Tree, -Value)
% Declaratively: Tree is an expression tree over the non-empty list List
% whose evaluation is defined (every division exact, divisor non-zero)
% and equals Value.
% Base case: a one-element list [N] has the leaf N, with value N.
% Recursive case: a list with at least two elements has the tree
% e(Op, L, R) and value V if List splits into non-empty Left and Right,
% L (value VL) is a tree over Left, R (value VR) is a tree over Right,
% and applying Op to VL and VR is defined and gives V.
% The value is computed while the tree is built, so a bad division
% fails at once and its subtree is never extended further.
expr_val([N], N, N).
expr_val([A, B|T], e(Op, L, R), V) :-
    split_list([A, B|T], Left, Right),
    expr_val(Left, L, VL),
    expr_val(Right, R, VR),
    arith_op(Op),
    apply_op(Op, VL, VR, V).

% fmt(+Tree, -String)
% Declaratively: String is the canonical SWI-Prolog string (no spaces) for
% the expression tree Tree.
% Base case: an integer leaf N is written in decimal, never in parentheses.
% Recursive case: e(Op,L,R) is the string of L, then Op, then the string of
% R, where each operand is wrapped in parentheses exactly when
% needs_parens/3 says so.
fmt(N, String) :-
    integer(N),
    format(string(String), "~d", [N]).
fmt(e(Op, L, R), String) :-
    prec(Op, P),
    fmt_operand(L, left, P, LString),
    fmt_operand(R, right, P, RString),
    format(string(String), "~w~w~w", [LString, Op, RString]).

% prec(+Op, -Precedence)
% Declaratively: Op has binding strength Precedence (higher binds tighter).
prec(+, 1).
prec(-, 1).
prec(*, 2).
prec(/, 2).

% fmt_operand(+Tree, +Side, +ParentPrec, -String)
% Declaratively: String is the text of the operand Tree sitting on Side
% (left or right) of a parent operator of precedence ParentPrec,
% parenthesised exactly when needs_parens/3 holds.
% (The if-then-else is a local choice between two outputs, not a cut.)
fmt_operand(Tree, Side, ParentPrec, String) :-
    fmt(Tree, Plain),
    (   needs_parens(Tree, Side, ParentPrec)
    ->  format(string(String), "(~w)", [Plain])
    ;   String = Plain
    ).

% needs_parens(+Tree, +Side, +ParentPrec)
% Declaratively: Tree needs parentheses as the Side operand of a parent
% with precedence ParentPrec.
% Left operand: only if its top operator binds looser than the parent.
% Right operand: if its top operator binds equally or looser.
% An integer leaf never needs parentheses (no clause matches it).
needs_parens(e(Op, _, _), left, ParentPrec) :-
    prec(Op, P),
    P < ParentPrec.
needs_parens(e(Op, _, _), right, ParentPrec) :-
    prec(Op, P),
    P =< ParentPrec.
% equation(+List, -Str)
% Declaratively: Str is the canonical string "L=R" of an equation for List,
% where List splits (at some point j with 1 =< j < k) into a non-empty
% Left part and a non-empty Right part, L is an expression tree over
% Left with value VL, R is an expression tree over Right with value VR,
% and VL equals VR.
% Fails for lists of length 0 or 1, because they have no valid split.
equation(List, Str) :-
    split_list(List, Left, Right),
    expr_val(Left, LTree, Value),
    expr_val(Right, RTree, Value),
    fmt(LTree, LStr),
    fmt(RTree, RStr),
    format(string(Str), "~w=~w", [LStr, RStr]).
% generate_equation(+List, -Equation)
% Declaratively: Equation is one valid equation string for List, that is,
% some solution of equation/2.
% Fails (no error, no loop) if List has length 0 or 1, or if no valid
% equation exists.
% once/1 keeps only the first solution, so no choice point is left behind.
generate_equation(List, Equation) :-
    once(equation(List, Equation)).
% all_equations(+List, -Equations)
% Declaratively: Equations is the list of all valid equation strings for
% List, without duplicates, in standard order of terms (sort/2).
% It is [] if List has no valid equation, including lists of length 0 or 1.
all_equations(List, Equations) :-
    findall(Str, equation(List, Str), All),
    sort(All, Equations).

% count_equations(+List, -N)
% Declaratively: N is the number of valid equations for List, i.e. the
% length of the list given by all_equations/2.
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).
