:- use_module(library(lists)).

% solution(-Solution)
% Declaratively: Solution is a list of four terms p(Name, Dept, Lang, Project),
% in the order 'Alex', 'Ben', 'Carla', 'Dana', in which each attribute uses
% each of its four allowed values exactly once.
% Generates all 24 * 24 * 24 = 13824 candidate assignments on backtracking.
solution([p('Alex',  D1, L1, P1),
          p('Ben',   D2, L2, P2),
          p('Carla', D3, L3, P3),
          p('Dana',  D4, L4, P4)]) :-
    permutation([research, development, design, testing],  [D1, D2, D3, D4]),
    permutation([python, java, 'c++', javascript],         [L1, L2, L3, L4]),
    permutation(['AI', web, embedded, data],               [P1, P2, P3, P4]).
clue(1, Solution) :-
    member(p(Name, Dept, _, 'AI'), Solution),
    Name \== 'Dana',
    Dept \== research.
clue(2, Solution) :-
    member(p('Alex', Dept, Lang, _), Solution),
    Dept \== development,
    Lang \== 'c++'.
clue(3, Solution) :-
    member(p(_, testing, Lang, _), Solution),
    Lang == python.
clue(4, Solution) :-
    member(p('Ben', Dept, _, Project), Solution),
    Project == web,
    Dept \== testing.            
clue(5, Solution) :-
    member(p(_, Dept, java, _), Solution),
    Dept == design.
clue(6, Solution) :-
    member(p('Carla', Dept, _, Project), Solution),
    Project \== embedded,
    Dept \== development.