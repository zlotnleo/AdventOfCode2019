count_consecutive([], []).
count_consecutive([A | Tail], [(A, X) | Counts]) :- count_consecutive(Tail, [(A, Y) | Counts]), !, X is Y + 1.
count_consecutive([A | Tail], [(A, 1) | Counts]) :- count_consecutive(Tail, Counts).

two_adjacent([(_, N) | _]) :- N >= 2, !.
two_adjacent([_ | Tail]) :- two_adjacent(Tail).

exactly_two_adjacent([(_, 2) | _]) :- !.
exactly_two_adjacent([_ | Tail]) :- exactly_two_adjacent(Tail).

nondecreasing([_]).
nondecreasing([A, B | Tail]) :- A =< B, nondecreasing([B | Tail]).


password_one(P) :- between(245182, 790572, P), number_codes(P, CharCodes), maplist(plus(48), Password, CharCodes),
    count_consecutive(Password, Counts), two_adjacent(Counts),
    nondecreasing(Password).

:- setof(P, password_one(P), Result), length(Result, Count), writeln(Count).


password_two(P) :- between(245182, 790572, P), number_codes(P, CharCodes), maplist(plus(48), Password, CharCodes),
    count_consecutive(Password, Counts), exactly_two_adjacent(Counts),
    nondecreasing(Password).

:- setof(P, password_two(P), Result), length(Result, Count), writeln(Count).