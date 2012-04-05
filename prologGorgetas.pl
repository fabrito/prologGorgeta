% Autor:  Flavio Ferreira de Brito
% Data: 31/03/2012

% Funções Auxiliares


%Retorna o tamanho de uma lista
tamanho([],Resultado) :- Resultado is 0.
tamanho([A | B],Resultado) :- tamanho(B,R), Resultado is R + 1.

%Retorna o maior elemento de uma lista
max([],Resultado) :- Resultado is -10000.
max([A | B],Resultado) :- max(B, R), (A >= R, Resultado is A ; Resultado is R), !.

%Retorna o menor elemento de uma lista
min([],Resultado) :- Resultado is 100000.
min([A | B],Resultado) :- min(B, R), (A >= R, Resultado is R ; Resultado is A), !.


% Funções de Pertinência


triangular(X,[A,B,C],Resultado) :- min([(X-A)/(B-A), (C-X)/(C-B)], M), max([M,0],R), Resultado is R.
trapezoidal(X,[A,B,C,D],Resultado) :- min([(X-A)/(B-A), 1, (D-X)/(D-C)], M), max([M,0],R), Resultado is R.


% Calcula o centro de um polígono


centroideA(Tam,Conj,[],Resultado) :- Resultado is 0.
centroideA(Tam,Conj,[A | B],Resultado) :-
     centroideA(Tam, Conj, B, Res),
     (Tam =:= 4, trapezoidal(A,Conj,Tmp),! ; triangular(A,Conj,Tmp),!),
     Resultado is Res + A*Tmp.

centroideB(Tam, Conj,[],Resultado) :- Resultado is 0.
centroideB(Tam, Conj,[A | B],Resultado) :-
     centroideB(Tam, Conj, B, Res),
     (Tam =:= 4, trapezoidal(A,Conj,Tmp),! ; triangular(A,Conj,Tmp),!),
     Resultado is Res + Tmp.

centroide(Conj, Resultado) :-
     tamanho(Conj, Tam),
     centroideA(Tam,Conj,Conj,A),
     centroideB(Tam,Conj,Conj,B),
     (B > 0, Resultado is A / B ; Resultado is 0).


% Conjuntos Fuzzy

%Delimitação dos conjuntos
ruim([0,1,2,4]).
regular([2,4,6]).
bom([4,6,8]).
otimo([6,8,10,10]).

gorgetaFraca([0,1,3,6]).
gorgetaRegular([3,6,9]).
gorgetaBoa([6,9,12]).
gorgetaOtima([9,12,15,15]).

%Funções de pertinência para cada conjunto

fn_comida_ruim(X,P) :- ruim(Conj), trapezoidal(X,Conj,P).
fn_comida_regular(X,P) :- regular(Conj), triangular(X,Conj,P).
fn_comida_bom(X,P) :- bom(Conj), triangular(X,Conj,P).
fn_comida_otimo(X,P) :- otimo(Conj), trapezoidal(X,Conj,P).

fn_atendimento_ruim(X,P) :- ruim(Conj), trapezoidal(X,Conj,P).
fn_atendimento_regular(X,P) :- regular(Conj), triangular(X,Conj,P).
fn_atendimento_bom(X,P) :- bom(Conj), triangular(X,Conj,P).
fn_atendimento_otimo(X,P) :- otimo(Conj), trapezoidal(X,Conj,P).

fn_gorgeta_fraca(X,P) :- gorgetaFraca(Conj), trapezoidal(X,Conj,P).
fn_gorgeta_regular(X,P) :- gorgetaRegular(Conj), triangular(X,Conj,P).
fn_gorgeta_boa(X,P) :- gorgetaBoa(Conj), triangular(X,Conj,P).
fn_gorgeta_otima(X,P) :- gorgetaOtima(Conj), trapezoidal(X,Conj,P).

%Variaveis Linguisticas

qualidadeAtendimento(X,Pertinencia) :- fn_atendimento_ruim(X,Ru), fn_atendimento_regular(X,Re), fn_atendimento_bom(X,B), fn_atendimento_otimo(X,O), Pertinencia = [Ru,Re,B,O].
qualidadeComida(X,Pertinencia) :- fn_comida_ruim(X,Ru), fn_comida_regular(X,Re), fn_comida_bom(X,B), fn_comida_otimo(X,O), Pertinencia = [Ru,Re,B,O].
gorgeta(X,Pertinencia):- fn_gorgeta_fraca(X,F), fn_gorgeta__regular(X,R), fn_gorgeta_boa(X,Bo), fn_gorgeta_otima(X,Ot), Pertinencia = [F,R,Bo,Ot].


% Regras de inferência e implicação


% Se Atendimento = otimo , Comida = otimo Então Gorgeta = otima
regra1([Aru,Are,Ab,Ao],[Cru,Cre,Cb,Co],[Gf,Gr,Gb,Go],) :- min(Ao,Co,Tmp), Go is Tmp.

% Se Atendimento = bom , Comida = bom Então Gorgeta = boa
regra2([Aru,Are,Ab,Ao],[Cru,Cre,Cb,Co],[Gf,Gr,Gb,Go]) :- min(Ab,Cb,Tmp), Gb is Tmp.

% Se Atendimento = regular , Comida = regular Então Gorgeta = regular
regra3([Aru,Are,Ab,Ao],[Cru,Cre,Cb,Co],[Gf,Gr,Gb,Go]) :- min(Ao,Co,Tmp), Go is Tmp.

% Se Atendimento = ruim , Comida = ruim Então Gorgeta = fraca
regra4([Aru,Are,Ab,Ao],[Cru,Cre,Cb,Co],[Gf,Gr,Gb,Go]) :- min(Ao,Co,Tmp), Go is Tmp.


% Defuzzyficação


defuzzyficacao([Aru,Are,Ab,Ao],[Cru,Cre,Cb,Co],[Gf,Gr,Gb,Go]) :-
       ruim(Ruim),centroide(Ruim,RuOut),
       regular(Regular),centroide(Regular,ReOut),
       bom(Bom),centroide(Bom,BOut),
       otimo(Otimo),centroide(Otimo,OOut),
       Resultado is RuOut*Ru + Re*ReOut + B*BOut + O*OOut, !.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controlador fuzzy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

controladorFuzzy(Comida,Atendimento,Gorjeta) :-

      %Fuzzyficação
      temperatura(Comida,Atendimento, G),

      % Inferência - Implicação e Agregação
      regra1(P,A),
      regra2(P,B),
      regra3(P,C),
      regra4(P,D),

      %Defuzzyficação
      defuzzyficacao([A,B,C,D],Gorgeta), !.