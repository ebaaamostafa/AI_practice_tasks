:- consult('data_process.pl').

% validating a new position
valid_move((X,Y),Visited) :-
    \+ member((X,Y), Visited),
    X >= 0,
    Y >= 0,
    grid_size(R,C),
    X < R,
    Y < C,
    \+ obstacle(X,Y).

% defining the drone's movement
left((X,Y),(X,NewY)) :-
    NewY is Y - 1.

right((X,Y),(X,NewY)) :-
    NewY is Y + 1.

up((X,Y),(NewX,Y)) :-
    NewX is X - 1.

down((X,Y),(NewX,Y)) :-
    NewX is X + 1.

% defining the drone's next move
move((X,Y), (NewX,NewY), Visited) :-
    (left((X,Y), (NewX,NewY));
     right((X,Y), (NewX,NewY));
     up((X,Y), (NewX,NewY));
     down((X,Y), (NewX,NewY))),
    valid_move((NewX,NewY), Visited).

% base case for the DFS
dfs((X,Y),Path,NumOfDelivers,NumOfDelivers,Path) :-
    \+ move((X,Y), (_,_), Path).

% recursive case for the DFS
% it will check if the new position is valid and if it is a delivery point
% if it is a delivery point -> it will increase the number of deliveries
% else -> nothing
% and append the new position to the path
dfs((X,Y),Path,NumOfDelivers,FinalDel,FinalPath) :-
    move((X,Y), (NewX,NewY), Path),
    valid_move((NewX,NewY), Path),
    (
        delivery(NewX,NewY) ->
        NewNumOfDelivers is NumOfDelivers + 1 ;
        NewNumOfDelivers = NumOfDelivers
    ),
    append(Path, [(NewX,NewY)], NewPath),
    dfs((NewX,NewY), NewPath, NewNumOfDelivers,FinalDel,FinalPath).


% main function to find the optimal path
% it will process the grid and detect the position of the drone
% then will find all paths
% then it will find the maximum number of deliveries and the path
% with the maximum number of deliveries
% it will return the path and the number of deliveries
solve(Grid,OptimalPath,MaxDelivers) :-
    process_grid(Grid),
    drone(X,Y),
    findall(Delivers-Paths, dfs((X,Y), [(X,Y)], 0, Delivers, Paths), AllPaths),
    max_member(MaxDelivers-OptimalPath, AllPaths),
    writeln('--- Drone Route ---'),
    draw_grid(Grid),
    drawAllPath(Grid , OptimalPath).
    


drawAllPath(Grid, [( _ , _)]) :-
    writeln('--- Final Path ---'),
    draw_grid(Grid),
    writeln('Final path reached!'),!.

drawAllPath(Grid, [(A, B),(C, D) | Rest]) :-
    nl,update_grid(Grid, A, B, w , TempGrid), 
    update_grid(TempGrid, C, D, d , UpdatedGrid), 
    draw_grid(UpdatedGrid), nl,
    drawAllPath(UpdatedGrid, [(C , D) | Rest]).


update_grid([Row | Rest], 0, Y, Char, [UpdatedRow | Rest]) :-
    update_row(Row, Y, Char, UpdatedRow),!.

update_grid([Row | Rest], X, Y, Char, [Row | UpdatedRest]) :-
    X > 0, 
    NewX is X - 1,
    update_grid(Rest, NewX, Y, Char, UpdatedRest).

% update_row(+Row, +Y, +Char, -UpdatedRow)
update_row([_ | Rest], 0, Char, [Char | Rest]).
update_row([Cell | Rest], Y, Char, [Cell | UpdatedRest]) :-
    Y > 0,
    NewY is Y - 1,
    update_row(Rest, NewY, Char, UpdatedRest).
    
print_cell(d) :-
    write('D').

print_cell(p) :-
    write('P').

print_cell(w) :-
    write('*').

print_cell(o) :-
    write('O').

print_cell(e) :-
    write('-').

print_row([]).
print_row([F | R]):-
    print_cell(F),
    write(" "),
    print_row(R).


draw_grid([]).

draw_grid([R | T]):-
    print_row(R),nl
    ,draw_grid(T).