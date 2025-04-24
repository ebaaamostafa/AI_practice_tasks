make_positions([],_).
make_positions([Row|Rest],Index) :-
    make_positions_row(Row,Index,0),
    NextIndex is Index + 1,
    make_positions(Rest,NextIndex).

make_positions_row([], _, _).

make_positions_row([p|Rest], RowIndex, ColumnIndex) :-
    assertz(delivery(RowIndex, ColumnIndex)),
    NewIndex is ColumnIndex + 1,
    make_positions_row(Rest, RowIndex, NewIndex).

make_positions_row([Element|Rest], RowIndex, ColumnIndex) :-
    (
        % if -> then ; else
        Element = d -> assertz(drone(RowIndex, ColumnIndex)) ;
        Element = p -> assertz(delivery(RowIndex, ColumnIndex)) ;
        Element = o -> assertz(obstacle(RowIndex, ColumnIndex)) ;
        Element = e -> assertz(empty(RowIndex, ColumnIndex))
    ),
    NewIndex is ColumnIndex + 1,
    make_positions_row(Rest, RowIndex, NewIndex).

% make_positions_row([d|Rest], RowIndex, ColumnIndex) :-
%     assertz(drone(RowIndex, ColumnIndex)),
%     NewIndex is ColumnIndex + 1,
%     make_positions_row(Rest, RowIndex, NewIndex).


% make_positions_row([o|Rest], RowIndex, ColumnIndex) :-
%     assertz(obstacle(RowIndex, ColumnIndex)),
%     NewIndex is ColumnIndex + 1,
%     make_positions_row(Rest, RowIndex, NewIndex).

% make_positions_row([e|Rest], RowIndex, ColumnIndex) :-
%     assertz(empty(RowIndex, ColumnIndex)),
%     NewIndex is ColumnIndex + 1,
%     make_positions_row(Rest, RowIndex, NewIndex).


process_grid(Grid) :-
    % delete all old facts
    retractall(drone(_,_)),
    retractall(obstacle(_,_)),
    retractall(delivery(_,_)),
    retractall(grid_size(_,_)),

    length(Grid, RowLength),
    Grid = [FirstRow|_],
    length(FirstRow, ColumnLength),
    % makes new facts
    assertz(grid_size(RowLength, ColumnLength)),

    make_positions(Grid,0).