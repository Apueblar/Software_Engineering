% Practice 3: Euclidean Spaces
clear
clc
%% Linear Spaces: Vactor Systems
% Col vectors
v1 = [3 0 1 -2]';
v2 = [2 -1 0 -4]';
v3 = [1 0 0 2]';
u = [1 2 3 4]';
w = [0 1 1 0]';

%Independence
S = [v1 v2 v3]; % S is a basis set
r = rank(S); % rank(S) -> Vectores independientes
% E = rref(S) -> Te hace Gaus

% Linear Combinations
% u or w are inside of <S>?
Su = [S u];
ru = rank(Su); % r=4 -> u is independiente -> No linear combination

Sw = [S w];
rw = rank(Sw); % r=3 -> w is a linear combination

% Coordinates of w in the basis S
Ew = rref(Sw) %Solution of is the last column
C = Ew(1:3,end) % Coordinates

%% U+V and U∩V
u1 = [3 0 1 -2]'; u2 = [2 -1 0 -4]'; u3 = [1 0 0 2]';
v1 = [1 2 3 4]'; v2 = [0 1 1 0]';

% U+V
M = [u1 u2 u3 v1 v2]';
E = rref(M); %The standar basis of R4

% U∩V
% Solutions of the homg. system M'
solution = null(M') % M' contains vectors as colums
sol1 = null(sym(M')) % -t = 1 -> t = -1 -> v = -v2 Porque da -1 1 1 0 y los últimos dos son sol pero el penultimo es 0 por lo que la solución es el vector ultimo * -1
% -u1 +u2 +u3 +v2 = 0 -> -u1 +u2 +u3 = -v2 => v
%% Scalar Product: Compare Vectors
clear
clc
close all
% Da igual si son filas o columnas pero todos iguales
v1 = [4 5 6];
v2 = [-1 6 -3];
v3 = [3 0 5];
w = [1 2 3];
o = [0 0 0]; % Origen

% Mostrar dibujados los vectores con origen en o = [0,0,0]

plot3([o(1) v1(1)],[o(2) v1(2)],[o(3) v1(3)],'red-^')
hold on % continuar en la misma ventana
plot3([o(1) v2(1)],[o(2) v2(2)],[o(3) v2(3)],'green-^')
plot3([o(1) v3(1)],[o(2) v3(2)],[o(3) v3(3)],'blue-^')

plot3([o(1) w(1)],[o(2) w(2)],[o(3) w(3)],'mag-^')

% Distances: v3 is the closest (La menor distancia)
d1 = norm(v1-w)
d2 = norm(v2-w)
d3 = norm(v3-w)

% Angles: v1 is the closest (El mayor cos)
cos1 = dot(v1,w) / (norm(v1) * norm(w))
cos2 = dot(v2,w) / (norm(v2) * norm(w))
cos3 = dot(v3,w) / (norm(v3) * norm(w))
