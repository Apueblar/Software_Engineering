clear
clc
%% Ex1:
v1 =[1 -2 -2 -3]';
v2 =[1 ,1 2 -1]';
v3 =[-2 2 2 1]';
v = [v1 v2 v3]
rank(v)
u =[-3 3 3 1]';
w = [1 2 4 -4]';
vu = [v u];
rvu = rank(vu);

vw = [v w];
rvw = rank(vw);

msol = rref(vw);
sol = msol(1:3,end)
%% Ex2:
u1 = [0 0 -1 1]';
u2 = [2 2 1 0]';
u3 = [1 0 -2 -2]';
v1 = [0 1 2 1]';
v2 = [-1 -2 -5 -4]';

U = [u1 u2 u3]';
W = [v1 v2]';
M = [u1 u2 u3 v1 v2]';

dimU = rank(U);
dimW = rank(W);
dimM = rank(M);

E = rref(M);
sol1 = null(sym(M'))
dimint = rank(sol1)

sol = 0 * v1 + v2

