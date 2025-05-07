%% Practice 10
%% Linear Systems: Iterative Methods
%% Jacobi:
clear
clc
% Ax=b
A = [ 4 -1 1; 4 -8 1; -2 1 5];
b = [7 -21 15]'; % Column vector

tol = 10^-6;
Nmax = 100;

[sol, k] = Jacobi_matrix_form(A,b,tol,Nmax)

[sol2, k2] = Jacobi_iteration(A,b,tol,Nmax)


%% Gauss - Seidel
clear
clc

A = [10 -1 2 0; -1 11 -1 3; 2 -1 10 -1; 0 3 -1 8]
b = [6 25 -11 15]';

tol = 10^-6;
Nmax = 100;

[sol, k] = Gauss_Seidel_iter(A,b,tol,Nmax)

%% Non Linear Systems
clear
close all
clc

syms x y
f1(x,y) = (x+1)^3 - x - y^2;
f2(x,y) = x+3/2-y;
f_sym(x,y) = [f1(x,y);f2(x,y)];

ezplot('y^2=(x+1)^3-x', [-3 3 -8 8]), hold on
ezplot('y = x+3/2')

J_sym = jacobian(f_sym);
J_num = matlabFunction(J_sym);
J = @(z) J_num(z(1), z(2)); % Vector Jacobian

f_num = matlabFunction(f_sym);
f = @(z) f_num(z(1), z(2)); % Vector

% Newton Raphson Method:
tol = 10^-6;
Nmax = 100;

% x0=[0,2]';
x0=[-2,0]';

[sol,k] = newton_systems(f,J,x0,tol,Nmax)























































