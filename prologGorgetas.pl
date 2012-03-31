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

fn_ruim(X,P) :- ruim(Conj), trapezoidal(X,Conj,P).
fn_regular(X,P) :- regular(Conj), triangular(X,Conj,P).
fn_bom(X,P) :- bom(Conj), triangular(X,Conj,P).
fn_otimo(X,P) :- otimo(Conj), trapezoidal(X,Conj,P).

fn_gorgetaFraca(X,P) :- gorgetaFraca(Conj), trapezoidal(X,Conj,P).
fn_gorgetaRegular(X,P) :- gorgetaRegular(Conj), triangular(X,Conj,P).
fn_gorgetaBoa(X,P) :- gorgetaBoa(Conj), triangular(X,Conj,P).
fn_gorgetaOtima(X,P) :- gorgetaOtima(Conj), trapezoidal(X,Conj,P).

%Variaveis Linguisticas

qualidadeAtendimento(X,Pertinencia) :- fn_ruim(X,Ru), fn_regular(X,Re), fn_bom(X,B), fn_otimo(X,O), Pertinencia = [Ru,Re,B,O].
qualidadeComida(X,Pertinencia) :- fn_ruim(X,Ru), fn_regular(X,Re), fn_bom(X,B), fn_otimo(X,O), Pertinencia = [Ru,Re,B,O].


% Regras de inferência e implicação
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Se Atendimento = otimo , Comida = otimo Então Gorgeta = otima
regra1([Ru,Re,B,O],Resultado) :- O > 0, Resultado is O ; Resultado is 0.

% Se SensacaoTermica = morno Então ArCondicionado = fresco
regra2([Q,M,Fc,Fr],Resultado) :- M > 0, Resultado is M ; Resultado is 0.

% Se SensacaoTermica = fresco Então ArCondicionado = morno
regra3([Q,M,Fc,Fr],Resultado) :- Fc > 0, Resultado is Fc ; Resultado is 0.

% Se SensacaoTermica = frio Então ArCondicionado = quente
regra4([Q,M,Fc,Fr],Resultado) :- Fr > 0, Resultado is Fr ; Resultado is 0.
