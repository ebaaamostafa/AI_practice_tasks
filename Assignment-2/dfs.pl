consult('data_process.pl').

% validating the new position
valid_move((X,Y),Visited) :-
    \+ member((X,Y), Visited),
    X >= 0,
    Y >= 0,
    grid_size(R,C),
    X < R,
    Y < C,
    \+ obstacle(X,Y).

left((X,Y),(X,NewY)) :-
    NewY is Y - 1.

right((X,Y),(X,NewY)) :-
    NewY is Y + 1.

up((X,Y),(NewX,Y)) :-
    NewX is X - 1.

down((X,Y),(NewX,Y)) :-
    NewX is X + 1.

move((X,Y), (NewX,NewY), Visited) :-
    (left((X,Y), (NewX,NewY));
     right((X,Y), (NewX,NewY));
     up((X,Y), (NewX,NewY));
     down((X,Y), (NewX,NewY))),
    valid_move((NewX,NewY), Visited).

% base case
dfs((X,Y),Visited) :-
    \+ move((X,Y), (_,_), Visited).

dfs((X,Y),Path,NumOfDelivers) :-
    move((X,Y), (NewX,NewY), Path),
    valid_move((NewX,NewY), Path),
    (
        delivery(NewX,NewY) ->
        NewNumOfDelivers is NumOfDelivers + 1 ; 
        NewNumOfDelivers = NumOfDelivers
    ),
    dfs((NewX,NewY), [(NewX,NewY)|Path], NewNumOfDelivers).


