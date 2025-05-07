% Practice 5: Linear Systems Ax = b
%% Full Rank:
% rank(A) = min(m,n)
% m is equations and n are the unknowns.

% m = n -> S.C.D. -> sol = A^-1 * b = A\b
% m < n -> S.C.I. -> sol = inf
% m > n -> Overdeterminated -> sol = Least Square sol

%% I. CDS - m = n
clear 
clc
A = randi([-3,3],4) % Square 4 * 4
r = rank(A) % 4

b = randi([-4,4],4,1) % 4 * 1 matrices

% Direct
sol1 = inv(A) * b
% Gauss
Amp = [A b];
E = rref(Amp);
sol2 = E(:,end)
% sol1 = sol2

%% II. C Undetermined: m < n -> Exist infinity sol
clear
clc

A = randi([-3,3],3,4)
r = rank(A); % 3

b = randi([-4,4],3,1) % 4 * 1 matrices

% Direct solve
syms x y z t
X = [x y z t].';
sol1 = solve(A * X == b,'ReturnConditions',true);
xs = sol1.x;
ys = sol1.y;
zs = sol1.z;
ts = t;
Xsol = [xs ys zs ts].' % Sol vector

% Gauss
Amp = [A b];
E = rref(Amp);
syms a % parameter
sol2 = E(:,end) - a * E(:,end -1);
sol2 = [sol2; a]

%% III. Overdeterminad: m > n -> sol don't exist -> Least Square
clear
clc

A = randi([-3,3],5,3);
r = rank(A); % 3 = min(5,3)

b = randi([-4,4],5,1);

% Gauss
Amp = [A b];
E = rref(Amp); % No sol

% Least Squares (Approximation)
sol = A\b

%% Rank Deficient:
% rank(A) < min(m,n)
clear
clc

A = randi([-3,3],5,3);
col4 = 3 * A(:,1) - 2 * A(:,2) + 5 * A(:,3);
A = [A col4]
r = rank(A); % 3

b = randi([-4,4],5,1);

% Gauss
Amp = [A b];
E = rref(Amp); % No sol


% inv(A) -> Error
sol = pinv(A) * b
