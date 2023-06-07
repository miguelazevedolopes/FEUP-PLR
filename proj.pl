% consult('/Users/mafalda/Documents/FEUP/PLR/FEUP-PLR/proj.pl').

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

% FreezeTime e Appearance time só é usado no caso dinamico



aircraft_landing:-
% see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt'),
see('/Users/mafalda/Documents/FEUP/PLR/FEUP-PLR/airland1.txt'),
first_line_process(NumberPlanes,FreezeTime),
remaining_lines_process(NumberPlanes,AppearanceTimes,EarliestLandingTimes,TargetLandingTimes,LatestLandingTime,PenaltyBefore,PenaltyAfter,SeparationTimes),
seen,
length(LandingTimes,NumberPlanes),
all_distinct(LandingTimes),
enforce_earliest_and_latest_landing(EarliestLandingTimes,LatestLandingTime,LandingTimes),
% enforce_separation(1,SeparationTimes,LandingTimes), %o problema está aqui
length(TimesBefore,NumberPlanes),
length(TimesAfter,NumberPlanes),
times_before_target(TargetLandingTimes,LandingTimes,TimesBefore),
times_after_target(TargetLandingTimes,LandingTimes,TimesAfter),
scalar_product(PenaltyBefore,TimesBefore,#=,FirstVal),
scalar_product(PenaltyAfter,TimesAfter,#=,SecondVal),
Sum #= FirstVal + SecondVal,
labeling([minimize(Sum)],LandingTimes),
write(LandingTimes),nl,write(Sum).


% -------------- File Reading Predicates -------------- %

% Lê os valores de uma linha e converte os de char codes para numeros, retorna uma lista
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

% Lê os primeiros 2 valores (numero de avioes e freeze time)
first_line_process(NumberPlanes,FreezeTime):-
read_line(L), % read line é a função de sicstus para ler uma linha da input stream
read_line_values(L,Values),
[NumberPlanes,FreezeTime] = Values.

% -------------- Reading from Remaining Lines -------------- %

% Lê os valore de cada um dos aviões
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


% -------------- Constraints -------------- %


enforce_earliest_and_latest_landing([],[],[]).

% enforce_earliest_and_latest_landing(Earliest Landing Time,Latest Landing Time,Landing Times)
enforce_earliest_and_latest_landing([HELT|TELT],[HLLT|TLLT],[HLT|TLT]):-
domain([HLT],HELT,HLLT),
enforce_earliest_and_latest_landing(TELT,TLLT,TLT).



times_before_target([],[],[]):-!.
% times_before_target(Target Landing Times,Landing Times, Times Before Landing - αi)

times_before_target([HTLT|TTLT],[HLT|TLT],[HTB|TTB]):-
HTLT #> HLT,
HTB #>= 0,
HTB #= HTLT - HLT,
times_before_target(TTLT,TLT,TTB).

times_before_target([HTLT|TTLT],[HLT|TLT],[HTB|TTB]):-
HTLT #=< HLT,
HTB #= 0,
times_before_target(TTLT,TLT,TTB).

times_after_target([],[],[]):-!.

% times_before_target(Target Landing Times,Landing Times, Times After Landing - βi)
times_after_target([HTLT|TTLT],[HLT|TLT],[HTB|TTB]):-
HTLT #< HLT,
HTB #>= 0,
HTB #= HLT - HTLT,
times_after_target(TTLT,TLT,TTB).

times_after_target([HTLT|TTLT],[HLT|TLT],[HTB|TTB]):-
HTLT #>= HLT,
HTB #= 0,
times_after_target(TTLT,TLT,TTB).


% Isto está mal portanto ignora só
enforce_separation_plane([],_,[]).
enforce_separation_plane([HST|TST],LandingTime,[HLT|TLT]):-
LandingTime #> HLT,
HLT#>= LandingTime-HST,
enforce_separation_plane(TST,LandingTime,TLT).

enforce_separation(_,[],_).
enforce_separation(Index,[HST|TST],LandingTimes):-
element(Index,LandingTimes,LT),
enforce_separation_plane(HST,LT,LandingTimes),
I1 is Index+1,
enforce_separation(I1,TST,LandingTimes).
