
:- use_module(library(clpfd)).
:- use_module(library(lists)).

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

aircraft_landing(LandingTimes):-
see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt'),
first_line_process(NumberPlanes,_),
remaining_lines_process(NumberPlanes,_,EarliestLandingTimes,TargetLandingTimes,LatestLandingTimes,PenaltyBefore,PenaltyAfter,SeparationTimes),
seen,!,
length(LandingTimes,NumberPlanes),
length(TimesBefore,NumberPlanes),
length(TimesAfter,NumberPlanes),
all_distinct(LandingTimes),
enforce_earliest_and_latest_landing(EarliestLandingTimes,LatestLandingTimes,LandingTimes),
define_set_w(LatestLandingTimes,EarliestLandingTimes,SetW),




enforce_earliest_and_latest_landing([],[],[]).

% enforce_earliest_and_latest_landing(Earliest Landing Time,Latest Landing Time,Landing Times)
enforce_earliest_and_latest_landing([HELT|TELT],[HLLT|TLLT],[HLT|TLT]):-
domain([HLT],HELT,HLLT),
enforce_earliest_and_latest_landing(TELT,TLLT,TLT).



define_set_w_rec(IndexI,NumberPlanes,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW):-


define_set_w_rec(IndexI,IndexJ,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW):-
nth1(IndexI,LatestLandingTimes,Li),
nth1(IndexJ,EarliestLandingTimes,Ej),
nth1(IndexI,SeparationTimes,SepTimeListI),
nth1(IndexJ,SepTimeListI,Sij),
Li<Ej,
Li+Sij =< Ej,
NewIndexJ is IndexJ+1,
define_set_w_rec(IndexI,NewIndexJ,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetWTail),
SetW = [[IndexI,IndexJ]|SetWTail].

define_set_w_rec(IndexI,IndexJ,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW):-
NewIndexJ is IndexJ+1,
define_set_w_rec(IndexI,NewIndexJ,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW).



define_set_w(NumberPlanes,NumberPlanes,_,_,_,_).

define_set_w(IndexI,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW):-
NewIndexI is IndexI+1,
define_set_w_rec(IndexI,0,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW),
define_set_w(NewIndexI,NumberPlanes,LatestLandingTimes,EarliestLandingTimes,SeparationTimes,SetW).
