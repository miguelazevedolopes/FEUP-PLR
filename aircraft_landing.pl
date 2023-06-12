:- use_module(library(clpfd)).
:- use_module(library(lists)).

% Main predicate
aircraft_landing:-
see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/data/airland1.txt'),
first_line_process(NumberPlanes,_),
remaining_lines_process(NumberPlanes,_,EarliestLandingTimes,TargetLandingTimes,LatestLandingTimes,PenaltyBefore,PenaltyAfter,SeparationTimes),
seen,!,
statistics(runtime, [Start|_]),
length(LandingTimes,NumberPlanes),
all_distinct(LandingTimes),
create_before_matrix(NumberPlanes,NumberPlanes, IsBefore),
enforce_earliest_and_latest_landing(EarliestLandingTimes,LatestLandingTimes,LandingTimes),
Stop is NumberPlanes+1,
enforce_separation(1,Stop,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore), %o problema está aquilength(TimesBefore,NumberPlanes),
length(TimesAfter,NumberPlanes),
times_before_target(TargetLandingTimes,TimesBefore,EarliestLandingTimes),
times_after_target(TargetLandingTimes,TimesAfter,LatestLandingTimes),
relate_times_before_and_after(TimesBefore,TimesAfter,TargetLandingTimes,LandingTimes),
scalar_product(PenaltyBefore,TimesBefore,#=,FirstVal),
scalar_product(PenaltyAfter,TimesAfter,#=,SecondVal),
sum([FirstVal,SecondVal],#=,Sum),
append(TimesBefore,TimesAfter,TimesCombined),
append(TimesCombined,LandingTimes,ToLabel),
labeling([minimize(Sum),time_out(30000,Flag),down,bisect,dom_w_deg],ToLabel),
statistics(runtime, [End|_]),
ExecutionTime is End-Start,
nl,write('Sum: '),write(Sum),nl,write('Times After: '),write(TimesAfter),nl,write('Times Before: '),write(TimesBefore),nl,write('Execution Time: '),write(ExecutionTime),nl,write(Flag).


% -------------- File Reading Predicates -------------- %

% Reads the values ​​of a line and converts them from char codes to numbers, returns a list
read_line_values([],[]).

read_line_values(CurrentL,FinalList):-
get_values_from_codes(CurrentL,SubL,RestL),
read_line_values(RestL,F1),
number_codes(Value,SubL),
FinalList = [Value|F1].

% Reads the codes from the line. Stops when it encounters a space (code 32) or at the line end.
% get_values_from_codes(Current Line, Return Values, Remaing Codes in Line)
get_values_from_codes([],[],[]):-!.

get_values_from_codes([32|T],[],T):-!. 

get_values_from_codes([H|T],L,R):-
get_values_from_codes(T,L1,R),
L = [H|L1].

% -------------- Reading from First Line -------------- %

% Reads the first line
first_line_process(NumberPlanes,FreezeTime):-
read_line(L),
read_line_values(L,Values),
[NumberPlanes,FreezeTime] = Values.

% -------------- Reading from Remaining Lines -------------- %

% Reads the remaining lines after the first one
remaining_lines_process(0,[],[],[],[],[],[],[]):-!.
remaining_lines_process(NumberPlanes,AppearanceTimes,EarliestLandingTimes,TargetLandingTimes,LatestLandingTimes,PenaltyBefore,PenaltyAfter,SeparationTimes):-
read_line(L1), 
read_line_values(L1,Values),
[AT,ELT,TLT,LLT,PB,PA] = Values,
read_line(L2),
read_line_values(L2,ST),
CurrentPlane is NumberPlanes-1,
remaining_lines_process(CurrentPlane,TAT,TELT,TTLT,TLLT,TPB,TPA,TST),
AppearanceTimes = [AT|TAT],
EarliestLandingTimes = [ELT|TELT],
TargetLandingTimes = [TLT|TTLT],
LatestLandingTimes = [LLT|TLLT],
PenaltyBefore = [PB|TPB],
PenaltyAfter = [PA|TPA],
SeparationTimes = [ST|TST].


% -------------- Constraints -------------- %

% Enforces earliest and latest landing times for the Landing Times variable
%enforce_earliest_and_latest_landing(Earliest Landing Time, Latest Landing Time, Landing Time)
enforce_earliest_and_latest_landing([],[],[]).

enforce_earliest_and_latest_landing([HELT|TELT],[HLLT|TLLT],[HLT|TLT]):-
domain([HLT],HELT,HLLT),
enforce_earliest_and_latest_landing(TELT,TLLT,TLT).

% Determines the domain of the Times Before variable
%times_before_target(Target Landing Time, Times Before, Earliest Landing Times)
times_before_target([],[],[]).

times_before_target([HTLT|TTLT],[HTB|TTB],[HELT|TELT]):-
MaxDomain is HTLT-HELT,
domain([HTB],0,MaxDomain),
times_before_target(TTLT,TTB,TELT).

% Determines the domain of the Times After variable
%times_after_target(Target Landing Time, Times After, Latest Landing Times)
times_after_target([],[],[]).

times_after_target([HTLT|TTLT],[HTA|TTA],[HLLT|TLLT]):-
MaxDomain is HLLT-HTLT,
domain([HTA],0,MaxDomain),
times_after_target(TTLT,TTA,TLLT).

% Relates Times Before with Times After and the Landing Times
%relate_times_before_and_after(Times Before, Times After, Target Landing Times, Landing Times)
relate_times_before_and_after([],[],[],[]).

relate_times_before_and_after([HTB|TTB],[HTA|TTA],[HTLT|TTLT],[HLT|TLT]):-
minimum(0,[HTB,HTA]),
HLT#=HTLT-HTB+HTA,
relate_times_before_and_after(TTB,TTA,TTLT,TLT).

% Recursive auxiliar predicate to enforce separation times
%enforce_separation_rec(IndexI,IndexJ,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore)
enforce_separation_rec(_,NumberPlanes,NumberPlanes,_,_,_,_,_).

enforce_separation_rec(IndexI,IndexJ,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore):-
nth1(IndexI,SeparationTimes,SubSepIJ),
nth1(IndexJ,SubSepIJ,SepTimeIJ),
nth1(IndexJ,SeparationTimes,SubSepJI),
nth1(IndexI,SubSepJI,SepTimeJI),
nth1(IndexI,IsBefore,IsBeforeI),
element(IndexJ,IsBeforeI,IsBeforeIJ),
nth1(IndexJ,IsBefore,IsBeforeJ),
element(IndexI,IsBeforeJ,IsBeforeJI),
element(IndexI,LandingTimes,Xi),
element(IndexJ,LandingTimes,Xj),
minimum(0,[IsBeforeIJ,IsBeforeJI]),
(IndexI#=IndexJ) #\/
((IndexI#\=IndexJ) #/\ (Xi#>=Xj+SepTimeJI) #/\ (IsBeforeJI)) #\/
((IndexI#\=IndexJ) #/\ (Xj#>=Xi+SepTimeIJ) #/\ (IsBeforeIJ)),
NewIndexJ is IndexJ+1, 
enforce_separation_rec(IndexI,NewIndexJ,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore).

% Enforce separation times
% enforce_separation(IndexI,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore)
enforce_separation(NumberPlanes,NumberPlanes,_,_,_,_,_).

enforce_separation(IndexI,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore):-
NewIndexI is IndexI+1,
enforce_separation_rec(IndexI,1,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore),
enforce_separation(NewIndexI,NumberPlanes,LandingTimes,SeparationTimes,LatestLandingTimes,EarliestLandingTimes,IsBefore).

% Creates a matrix with domain variables that are either 0 or 1, depending if plane i lands before plane j or vice versa
% create_before_matrix(NumberPlanes,Index,IsBefore)
create_before_matrix(_,0,[]).

create_before_matrix(NumberPlanes,Index,IsBefore) :-
length(CurrentBefore, NumberPlanes),
domain(CurrentBefore, 0, 1),
NewI is Index-1,
create_before_matrix(NumberPlanes, NewI, IsBefore1),
IsBefore = [CurrentBefore|IsBefore1].
