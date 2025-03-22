%:-consult(league_data).


% check for an element if it is a member of a list
member_in_list(X,[X|_]).

member_in_list(X,[_|T]) :-
    member_in_list(X,T).

% __________________________________________________________________ %

% task 1

players_in_team(Team,L):-
    find_players_in_team(Team, [], L),!.

find_players_in_team(Team,Member_list,L):-
    player(Player,Team,_),
    \+ member_in_list(Player,Member_list),
    append(Member_list, [Player], New_list),
    find_players_in_team(Team,New_list,L).
find_players_in_team(_,L,L):-!.

% __________________________________________________________________ %

% task 2

team_count_by_country(Country,Result) :-
    team_count_by_country(Country,Result,0,[]),!.

team_count_by_country(Country,Count,Result,AccList):-
    team(Team,Country,_),
    \+ member_in_list(Team,AccList),
    NewResult is Result + 1,
    team_count_by_country(Country, Count,
    NewResult,[Team|AccList]).

team_count_by_country(_,Count,Count,_).

% __________________________________________________________________ %

% task 3
% Find the team with the most championship titles
%
% find the first team and save his wins
% start comparing his wins with all other teams
% if he is the greatest among all:
%    continue to the cut operator (i.e. he is the greatest team)
% else:
%    the \+ fails, you backtrack to the previous line, and start
%    comparing a new team with all other teams
%
% time complexity: O(N^2) check every team with all other teams
% space complexity: O(N) recursion stack
most_successful_team(T) :-
    team(T, _, Wins),
    \+ (team(_, _, NewWins), NewWins > Wins),
    !.

% __________________________________________________________________ %

% task 4

matches_of_team(Team, L) :-
    find_matches_of_team(Team, [], L),!.

find_matches_of_team(Team, Matches_list, L) :-
    match(Team, Opponent, G1, G2),
    \+ member_in_list((Team, Opponent, G1, G2), Matches_list),
    append(Matches_list, [(Team, Opponent, G1, G2)], New_list), 
    find_matches_of_team(Team, New_list, L).

find_matches_of_team(Team, Matches_list, L) :-
    match(Opponent, Team, G1, G2),
    \+ member_in_list((Opponent, Team, G1, G2), Matches_list),
    append(Matches_list, [(Opponent, Team, G1, G2)], New_list), 
    find_matches_of_team(Team, New_list, L).

find_matches_of_team(_, L, L):-!.


% __________________________________________________________________ %

% task 5
%similar logic to task 2
num_matches_of_team(Team, Result) :-
    num_matches_of_team(Team,Result,0,[]),!.

num_matches_of_team(Team, Count, Result,AccList) :-
    match(Team,AnotherTeam,_,_), % get any other team which match with target team
    \+ member_in_list([Team,AnotherTeam],AccList),
    NewResult is Result + 1,
    num_matches_of_team(Team,Count, NewResult,[[Team,AnotherTeam]|AccList]).

% two predicates to get all (liverpool,_) && (_,liverpool)
num_matches_of_team(Team, Count, Result,AccList) :-
    match(AnotherTeam,Team,_,_), % get any other team which match with target team
    \+ member_in_list([AnotherTeam,Team],AccList),
    NewResult is Result + 1,
    num_matches_of_team(Team,Count, NewResult,[[AnotherTeam,Team]|AccList]).

num_matches_of_team(_,Count,Count,_):-!.

% __________________________________________________________________ %

% task 6
% Find the top goal scorer in the tournament
%
% Find a player P
% Check if his goals are greater than all players:
%     if true:
%         continue to the cut operator
%     else:
%         this branch fails, and you backtrack
top_scorer(P) :-
    goals(P, Goals),
    \+ (goals(_, NewGoals), NewGoals > Goals),
    !.

% __________________________________________________________________ %

%task 7

max(X,Y,X) :- % if x > y, make x to be the result
    X > Y.

max(X,Y,X) :-
    X = Y.

max(X,Y,Y) :- % otherwise
    X < Y.


% max of a pair of [Position frequence, Position].
max_list([X,T1],[Y,_],[X,T1]) :-
    X > Y.

max_list([X,T1],[Y,_],[X,T1]) :-
    X = Y.

max_list([X,_],[Y,T2],[Y,T2]) :-
    X < Y.


count_occurrences(_,[],0). 

% if the first element is the target --> increament by 1
count_occurrences(X,[X|T],Result) :-
    count_occurrences(X,T,NewResult),
    Result is NewResult + 1.

% else
count_occurrences(X,[_|T],Result) :-
    count_occurrences(X,T,Result).

get_occurrences_list(Team,Result) :-
    get_occurrences_list(Team,[],[],Result).

get_occurrences_list(Team,PlayerList,PositionList,ResultList) :-
    player(Player,Team,Position),
    \+ member_in_list(Player,PlayerList),
    get_occurrences_list(Team,[Player|PlayerList],[Position|PositionList],ResultList).

get_occurrences_list(_,_,ResultList,ResultList).


make_frequency_list(OccList,Result) :-
    make_frequency_list(OccList,[],Result).

make_frequency_list([],ResultList,ResultList). %base case: emptyList --> return FreqList

%FreqList: a list of [Position Frequency, Position] to be returned
%OccList: occurrence list which have the duplicates
make_frequency_list([Pos|OccList],FreqList,ResultList) :-
    \+ member_in_list([_,Pos],FreqList), % if this position hasn't been counted before, continue and count
    count_occurrences(Pos,[Pos|OccList],Freq),
    make_frequency_list(OccList,[[Freq,Pos]|FreqList],ResultList).

make_frequency_list([_|OccList],FreqList,ResultList) :- % else if it has been counted, continue with the remaining list
    make_frequency_list(OccList,FreqList,ResultList).



% after I got the frequence list, I neet to get the max record of them
get_max_record([[X,Y]],[X,Y]). % base case: one element --> return it

get_max_record([H|T],Result) :-
    get_max_record(T,NewResult),
    max_list(H,NewResult,Result). % compare the first element with the remaining and return the max



%main predicate: combine all the above to reach our purpose
most_common_position_in_team(Team, Pos) :-
    get_occurrences_list(Team,List), % get the Position list from the team
    make_frequency_list(List,ResultList), % pass the position list to get the frequency list
    get_max_record(ResultList,[_,Pos]), % pass the frequency list to get the max_record, and takes the position only
    !.
