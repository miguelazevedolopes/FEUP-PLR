:- use_module(library(clpfd)).
:- use_module(library(lists)).


% The format of these data files is:
% number of planes (p), freeze time
% for each plane i (i=1,...,p):
%    appearance time, earliest landing time, target landing time,
%    latest landing time, penalty cost per unit of time for landing
%    before target, penalty cost per unit of time for landing
%    after target
%    for each plane j (j=1,...p): separation time required after 
%                                 i lands before j can land

% Ti be the target (preferred) landing time for plane i (i=1,...,P)
% Gi be the penalty cost (≥ 0) per unit of time for landing before the target time Ti for plane i (i=1,...,P)
% αi=how soon plane i (i=1,...,P) lands before Ti
% Hi be the penalty cost (≥ 0) per unit of time for landing after the target time Ti for plane i (i=1,...,P)
% βi=how soon plane i (i=1,...,P) lands after Ti
% Minimizar Somatorio de (Gi*αi + Hi*βi) para i em NumberPlanes

% Appearance time só é usado no caso dinamico



aircraft_landing:-
see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt'),
first_line_process(NumberPlanes,FreezeTime),
remaining_lines_process(NumberPlanes,AppearanceTimes,EarliestLandingTimes,TargetLandingTimes,LatestLandingTime,PenaltyBefore,PenaltyAfter,SeparationTimes),
seen,
length(OrderLanding,NumberPlanes),
domain(OrderLanding,1,NumberPlanes),
enforce_earliest_landing(EarliestLandingTimes,OrderLanding),
enforce_latest_landing(LatestLandingTime,OrderLanding),
enforce_separation(SeparationTimes,OrderLanding),
length([TimesAfter,TimesBefore],NumberPlanes),
TimesDomain is NumberPlanes-1,
domain([TimesAfter,TimesBefore],0,TimesDomain),
times_before_target(TargetLandingTimes,OrderLanding,TimesBefore),
times_after_target(TargetLandingTimes,OrderLanding,TimesAfter),
scalar_product(TimesBefore,PenaltyBefore,FirstVal),
scalar_product(TimesAfter,PenaltyAfter,SecondVal),
Sum #= FirstVal + SecondVal,
labeling([minimize(Sum)],OrderLanding),
write(OrderLanding).


% -------------- File Reading Predicates -------------- %

read_line_values([],[]).

read_line_values(CurrentL,FinalList):-
get_values_from_codes(CurrentL,SubL,RestL),
read_line_values(RestL,F1),
number_codes(Value,SubL),
FinalList = [Value|F1].

get_values_from_codes([32|T],[],T):-!.

get_values_from_codes([H|T],L,R):-
get_values_from_codes(T,L1,R),
L = [H|L1].

% -------------- Reading from First Line -------------- %

first_line_process(NumberPlanes,FreezeTime):-
read_line(L), 
read_line_values(L,Values),
[NumberPlanes,FreezeTime] = Values.

% -------------- Reading from Remaining Lines -------------- %

remaining_lines_process(0,[],[],[],[],[],[],[]):-!.
remaining_lines_process(NumberPlanes,AppearanceTimes,EarliestLandingTimes,TargetLandingTimes,LatestLandingTime,PenaltyBefore,PenaltyAfter,SeparationTimes):-
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
LatestLandingTime = [LLT|TLLT],
PenaltyBefore = [PB|TPB],
PenaltyAfter = [PA|TPA],
SeparationTimes = [ST|TST].


read_file:-
see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt'),
first_line_process(NumberPlanes,FreezeTime),!,
remaining_lines_process(NumberPlanes,AppearanceTimes,EarliestLandingTimes,TargetLandingTimes,LatestLandingTime,PenaltyBefore,PenaltyAfter,SeparationTimes),!,
seen,!,
write(NumberPlanes),write(' '),write(FreezeTime),nl,
write(AppearanceTimes),
write(EarliestLandingTimes),
write(TargetLandingTimes),
write(LatestLandingTime),
write(PenaltyBefore),
write(PenaltyAfter),
write(SeparationTimes).
