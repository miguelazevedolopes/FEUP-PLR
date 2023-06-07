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


aircraft_landing(LandingTimes):-
see('/home/miguel/Documents/Faculdade/PLR/FEUP-PLR/airland1.txt'),
% see('/Users/mafalda/Documents/FEUP/PLR/FEUP-PLR/airland1.txt'),
first_line_process(NumberPlanes,_),
remaining_lines_process(NumberPlanes,_,EarliestLandingTimes,TargetLandingTimes,LatestLandingTimes,PenaltyBefore,PenaltyAfter,SeparationTimes),
seen,!,
length(LandingTimes,NumberPlanes),
all_distinct(LandingTimes),
enforce_earliest_and_latest_landing(EarliestLandingTimes,LatestLandingTimes,LandingTimes),
plane_i_lands_before_j_or_vice_versa(LandingTimes,LandingTimes),
enforce_separation(LandingTimes,SeparationTimes,LandingTimes), %o problema está aqui
length(TimesBefore,NumberPlanes),
length(TimesAfter,NumberPlanes),
times_before_target(TargetLandingTimes,LandingTimes,TimesBefore,EarliestLandingTimes),
times_after_target(TargetLandingTimes,LandingTimes,TimesAfter,LatestLandingTimes),
scalar_product(PenaltyBefore,TimesBefore,#=,FirstVal),
scalar_product(PenaltyAfter,TimesAfter,#=,SecondVal),
sum([FirstVal,SecondVal],#=,Sum),
write(LandingTimes),
labeling([minimize(Sum),time_out(600000,Flag),ffc,bisect],LandingTimes),
nl,write(Sum),nl,write(TimesAfter),write(TimesBefore),nl,write(Flag).


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


enforce_earliest_and_latest_landing([],[],[]).

% enforce_earliest_and_latest_landing(Earliest Landing Time,Latest Landing Time,Landing Times)
enforce_earliest_and_latest_landing([HELT|TELT],[HLLT|TLLT],[HLT|TLT]):-
domain([HLT],HELT,HLLT),
enforce_earliest_and_latest_landing(TELT,TLLT,TLT).



times_before_target([],[],[],[]).
% times_before_target(Target Landing Times,Landing Times, Times Before Landing - αi)

times_before_target([HTLT|TTLT],[HLT|TLT],[HTB|TTB],[HELT|TELT]):-
MaxDomain is HTLT-HELT,
domain([HTB],0,MaxDomain),
Val #= HTLT - HLT,
(HTLT #> HLT) #<=> X,
HTB #= Val*X,
times_before_target(TTLT,TLT,TTB,TELT).


times_after_target([],[],[],[]).

% times_before_target(Target Landing Times,Landing Times, Times After Landing - βi)
times_after_target([HTLT|TTLT],[HLT|TLT],[HTA|TTA],[HLLT|TLLT]):-
MaxDomain is HLLT-HTLT,
domain([HTA],0,MaxDomain),
Val #= HLT - HTLT,
(HTLT #< HLT) #<=> X,
HTA #= Val*X,
times_after_target(TTLT,TLT,TTA,TLLT).


enforce_separation_rec(_,[],[]).

enforce_separation_rec(CurrentL,[HLT|TLT],[HST|TST]):-
((CurrentL#\=HLT) #/\ (abs(CurrentL-HLT) #>= HST)) #\/ (CurrentL#=HLT),
enforce_separation_rec(CurrentL,TLT,TST).


% Isto está mal portanto ignora só
enforce_separation(_,[],_).

enforce_separation([CurrentL|TLT],[HST|TST],LandingTimes):-
enforce_separation_rec(CurrentL,LandingTimes,HST),
enforce_separation(TLT,TST,LandingTimes).

plane_i_lands_before_j_or_vice_versa_rec(_,[]).

plane_i_lands_before_j_or_vice_versa_rec(CurrentL,[HLT|TLT]):-
((CurrentL#\=HLT) #/\ ((CurrentL#>HLT)#\/ HLT#>CurrentL)) #\/ (CurrentL#=HLT),
plane_i_lands_before_j_or_vice_versa_rec(CurrentL,TLT).


plane_i_lands_before_j_or_vice_versa([],_).

plane_i_lands_before_j_or_vice_versa([HLT|TLT],LandingTimes):-
plane_i_lands_before_j_or_vice_versa_rec(HLT,LandingTimes),
plane_i_lands_before_j_or_vice_versa(TLT,LandingTimes).

