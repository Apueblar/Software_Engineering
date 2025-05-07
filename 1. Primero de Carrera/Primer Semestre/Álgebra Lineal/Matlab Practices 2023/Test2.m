clear
clc
%% Ex1:
% Define the vectors in S
v1 = [-2; 3; 2; -1];
v2 = [-2; 2; 2; -1];
v3 = [-3; 0; 2; -1];

A = [v1, v2, v3];
r = rank(A);

w = [-1 5 2 -1]'
Amp = [A w]
R = rref(Amp)
sol = R(:,end)

%% Ex2:
% Define the vectors in B
v1 = [1 0 0 2]';
v2 = [-2 -1 1 -3]';
v3 = [-1 2 -1 -3]';
v4 = [-1 -1 -3 -4]';

A = [v1, v2, v3, v4];
r = rank(A)

w = [4; 8; 6; 11];
Amp = [A w]
R = rref(Amp)
sol = R(:,end)

%% Ex3:

v = linspace(0, 1, 11); 
w = (1:2:10)';

A = [-1, 1, 3; 0, 1, 3; 0, 3, -3; 3, 3, -3];
O = ones(size(A,1),8);
B = [A O];
C = [v; B];
E = [w C];
S = sum(diag(E))
F = E(5,4)
r1 = rank(E)