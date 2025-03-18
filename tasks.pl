:-consult(league_data).

% check for an element if it is a member of a list
% usually using it to commulate iterated elements and prevent duplicates and infinite recursion
member_in_list(X,[X|_]).

member_in_list(X,[_|T]) :-
    member_in_list(X,T).




% task 2
team_count_by_country(Country,Result) :-
    team_count_by_country(Country,Result,0,[]).

team_count_by_country(Country,Count,Result,AccList):-
    team(Team,Country,_), % get some team which belong to this country
    \+ member_in_list(Team,AccList), % check if it have been already proccessed
    NewResult is Result + 1,
    team_count_by_country(Country, Count, NewResult,[Team|AccList]). % append the team to accumlate list

team_count_by_country(_,Count,Count,_). % base case: no team match --> return count





% task 5
%similar logic to task 2
num_matches_of_team(Team, Result) :-
    num_matches_of_team(Team,Result,0,[]).

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

num_matches_of_team(_,Count,Count,_).





%task 7 *not completed*

%max of two elements
max(X,Y,R) :-
    X > Y;
    X = Y,
    R is X.

max(X,Y,R) :-
    X < Y,
    R is Y.
    
count_occurrences(_,[],0). %counts occerrences of an element in a list

% if the first element is the target --> increament by 1
count_occurrences(X,[X|T],Result) :-
    count_occurrences(X,T,NewResult),
    Result is NewResult + 1.

% else
count_occurrences(X,[_|T],Result) :-
    count_occurrences(X,T,Result).


% predicate which get a list of all the position (with there duplicates with different players)
get_occurrences_list(Team,Result) :-
    get_occurrences_list(Team,[],[],Result).
    
get_occurrences_list(Team,PlayerList,PositionList,ResultList) :-
    player(Player,Team,Position), % get any player and his position in the targe team
    \+ member_in_list(Player,PlayerList),
    get_occurrences_list(Team,[Player|PlayerList],[Position|PositionList],ResultList).

get_occurrences_list(_,_,ResultList,ResultList).


% get a list of [frequency of position, position]
make_frequency_list(OccList,Result) :-
    make_frequency_list(OccList,[],Result).

make_frequency_list([],ResultList,ResultList).

make_frequency_list([First|OccList],FreqList,ResultList) :-
    \+ member_in_list([_,First],FreqList),
    count_occurrences(First,[First|OccList],Count),
    make_frequency_list(OccList,[[Count,First]|FreqList],ResultList).

make_frequency_list([_|OccList],FreqList,ResultList) :-
    make_frequency_list(OccList,FreqList,ResultList).
