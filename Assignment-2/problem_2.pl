% process_grid/1 (input grid)
:- consult('data_process.pl').
:- consult('problem_1.pl').

% valid_move/2 ((x,y), visited, Energy)
valid_move((X,Y),Visited, E) :-
    \+ member((X,Y), Visited),
    X >= 0,
    Y >= 0,
    grid_size(R,C),
    X < R,
    Y < C,
    \+ obstacle(X,Y),
    E > 0.

update_energy(Pos, _, NewE) :-
    recharge(X, Y),
    Pos = (X, Y), !,
    energy_limit(NewE).

update_energy(_, EIn, EOut) :- EOut is EIn - 1.


left((X,Y), (X,NewY), EIn, EOut) :-
    NewY is Y - 1, update_energy((X,NewY), EIn, EOut).

right((X,Y), (X,NewY), EIn, EOut) :-
    NewY is Y + 1, update_energy((X,NewY), EIn, EOut).

up((X,Y), (NewX,Y), EIn, EOut) :-
    NewX is X - 1, update_energy((NewX,Y), EIn, EOut).

down((X,Y), (NewX,Y), EIn, EOut) :-
    NewX is X + 1, update_energy((NewX,Y), EIn, EOut).


move(X, Y, NewX, NewY, Visited, EIn, EOut) :-
    Curr = (X,Y),
    (left(Curr, Next, EIn, EOut);
     right(Curr, Next, EIn, EOut);
     up(Curr, Next, EIn, EOut);
     down(Curr, Next, EIn, EOut)),
    Next = (NewX, NewY),
    valid_move(Next, Visited, EOut).

% calculates distance between two points
distance((X1,Y1),(X2,Y2),D) :-
    D is abs(X1-X2) + abs(Y1-Y2).

% End goal is to visit all delivery points
goal_state(VisitedDeliveries) :-
    findall((X,Y), delivery(X,Y), AllDeliveries),
    subset(AllDeliveries, VisitedDeliveries).

state(Position, VisitedDeliveries, Energy).

heuristic(state((X, Y), Visited, _), H) :-    % find all points not visited & store them in RemainingDeliveries
    findall(
        (DX,DY),
        (delivery(DX,DY),
        \+ member((DX,DY), Visited)),
        RemainingDeliveries),
     % if -> then ; else
    (RemainingDeliveries = [] -> H = 0; % if no remaining deliveries, then H = 0
    % else
    findall( % find all
        Dist,
        (
            member((DX,DY), RemainingDeliveries), % RemainginDeliveries
            distance((X,Y),(DX,DY),Dist) % distances
        ),
        Dists), % and store them in Ditsts list
    min_list(Dists, H) % extract min distance and store in H
    ).

node(State, Path, Cost, F).
% f(n) = g(n) + h(n) // (cost from start to node + heuristic value)

% a_star(open, closed, path, cost)
a_star([node(state(_, Visited, _), Path, Cost, _) | _], _, Path, Cost):-
    goal_state(Visited).
a_star([node(state((X,Y), Visited, E), Path, G, _) | MoreOpen], Closed, FinalPath, TotalCost) :-
    findall(
        node(state((NewX, NewY), NewVisited, NewE), [(NewX, NewY)|Path], NewG, F),
        (
            move(X, Y, NewX, NewY, Visited, E, NewE),
            \+ member(state((NewX, NewY), _, _), Closed),
            (delivery(NewX, NewY), \+ member((NewX, NewY), Visited)
                -> NewVisited = [(NewX, NewY)|Visited]; NewVisited = Visited),
            NewG is G + 1,
            heuristic(state((NewX, NewY), NewVisited, NewE), H),
            F is NewG + H
        ),
        Children),
    append(MoreOpen, Children, NewOpenUnsorted),
    sort(4, @=<, NewOpenUnsorted, NewOpen),
    a_star(NewOpen, [state((X,Y), Visited, E)|Closed], FinalPath, TotalCost).


solve(Grid, EnergyLimit, Path, Cost) :-
    process_grid(Grid, EnergyLimit),
    drone(X, Y),
    Start = state((X,Y), [], EnergyLimit),
    heuristic(Start, H),
    a_star([node(Start, [(X,Y)], 0, H)], [], RevPath, Cost),
    reverse(RevPath, Path).



